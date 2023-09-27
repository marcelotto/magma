defmodule Magma.Document do
  alias Magma.Vault

  import Magma.Utils, only: [init_fields: 2]

  @type t ::
          Magma.Concept.t()
          | Magma.Artefact.Prompt.t()
          | Magma.Artefact.PromptResult.t()
          | Magma.Artefact.Version.t()
          | Magma.Preview.t()

  @callback build_path(t()) :: {:ok, Path.t()}

  @callback title(t()) :: binary

  @callback load_document(t()) :: {:ok, t()} | {:error, any}

  @callback render_front_matter(t()) :: binary

  @fields [
    # the path of this document
    path: nil,
    # the name of the file (used for links)
    name: nil,
    # the raw text of the document without the YAML front matter
    content: nil,
    tags: nil,
    aliases: nil,
    created_at: nil,
    # additional YAML front matter
    custom_metadata: %{}
  ]
  def fields, do: @fields

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Document
      alias Magma.Document

      defstruct Magma.Document.fields() ++ unquote(additional_fields)

      def load(%__MODULE__{} = document), do: Document.Loader.load(document)
      def load(path), do: Document.Loader.load(__MODULE__, path)
      def load_linked(name), do: Document.Loader.load_linked(__MODULE__, name)

      def load!(document_or_path) do
        case load(document_or_path) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end
    end
  end

  @doc false
  def init(%_document_type{} = document, fields \\ []) do
    init_fields(
      document,
      [
        created_at: DateTime.utc_now(),
        tags: :magma |> Application.get_env(:default_tags) |> List.wrap(),
        aliases: []
      ]
      |> Keyword.merge(fields)
    )
  end

  @doc false
  def init_path(%document_type{} = document) do
    case apply(document_type, :build_path, [document]) do
      {:ok, path} -> {:ok, %{document | path: path, name: name_from_path(path)}}
      {:error, _} = error -> error
      undefined -> raise "Undefined result: #{inspect(undefined)}"
    end
  end

  @doc false
  def name_from_path(path) do
    Path.basename(path, Path.extname(path))
  end

  def create(%_document_type{} = document, opts \\ []) do
    cond do
      Magma.MixHelper.create_file(document.path, full_content(document), opts) ->
        Vault.index(document)

        {:ok, document}

      Keyword.get(opts, :ok_skipped, false) ->
        {:ok, document}

      true ->
        {:skipped, document}
    end
  end

  def save(%_document_type{} = document, opts \\ []) do
    with :ok <- Magma.MixHelper.save_file(document.path, full_content(document), opts) do
      {:ok, document}
    end
  end

  defp full_content(document) do
    render_front_matter(document) <> document.content
  end

  def render_front_matter(%document_type{} = document) do
    import Magma.Obsidian.View.Helper

    """
    ---
    magma_type: #{type_name(document_type)}
    #{document_type.render_front_matter(document)}
    created_at: #{document.created_at}
    tags: #{yaml_list(document.tags)}
    aliases: #{yaml_list(document.aliases)}
    ---
    """
  end

  def recreate(%document_type{} = document) do
    document
    |> reset_document()
    |> document_type.create(force: true)
  end

  def recreate!(document) do
    case recreate(document) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  defp reset_document(document) do
    %{document | content: nil, created_at: nil}
  end

  # an AST transformation would be better, but does an implicit normalization
  def content_without_prologue(document) do
    content = document.content

    case String.split(content, ~r{^\#.*\n}m, parts: 2) do
      [_, stripped_content] -> String.trim(stripped_content)
      _ -> raise "invalid document #{document.path}: no title header found"
    end
  end

  @doc """
  Returns the document type name for the given document.

  ## Example

      iex> Magma.Document.type_name(Magma.Concept)
      "Concept"

      iex> Magma.Document.type_name(Magma.Artefact.Prompt)
      "Artefact.Prompt"

      iex> Magma.Document.type_name(Magma.Artefact.PromptResult)
      "Artefact.PromptResult"

      iex> Magma.Document.type_name(Magma.Artefact.Version)
      "Artefact.Version"

      iex> Magma.Document.type_name(Magma.Text.Preview)
      "Text.Preview"

      iex> Magma.Document.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Document type: Magma.Vault

      iex> Magma.Document.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Document type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Document type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Document type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the document module for the given string.

  ## Example

      iex> Magma.Document.type("Concept")
      Magma.Concept

      iex> Magma.Document.type("Artefact.Prompt")
      Magma.Artefact.Prompt

      iex> Magma.Document.type("Vault")
      nil

      iex> Magma.Document.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :build_path, 1)
  end
end

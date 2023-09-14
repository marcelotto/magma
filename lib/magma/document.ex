defmodule Magma.Document do
  @type t ::
          Magma.Concept.t()
          | Magma.Artefact.Prompt.t()
          | Magma.Artefact.PromptResult.t()
          | Magma.Artefact.Version.t()

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
    custom_metadata: nil
  ]
  def fields, do: @fields

  @template_path :code.priv_dir(:magma) |> Path.join("templates")
  def template_path, do: @template_path

  @callback template :: module

  @callback load_document(t()) :: {:ok, t()} | {:error, any}

  @callback create_document(t()) :: {:ok, t()} | {:error, any}

  @callback build_path(t()) :: {:ok, Path.t()}

  alias Magma.Vault
  alias Magma.Document.Loader

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Document
      alias Magma.Document

      defstruct Magma.Document.fields() ++ unquote(additional_fields)

      @impl true
      def template, do: Module.concat(__MODULE__, Template)

      @impl true
      def create_document(%__MODULE__{} = document), do: {:ok, document}

      def create(%__MODULE__{} = document), do: Document.create(document)

      def load(%__MODULE__{} = document), do: Document.Loader.load(document)
      def load(path), do: Document.Loader.load(__MODULE__, path)

      def load!(document_or_path) do
        case load(document_or_path) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end

      defoverridable create_document: 1
    end
  end

  def template(%document_type{} = document) do
    Path.join(@template_path, document_type.document_template_path(document))
  end

  def name_from_path(path) do
    Path.basename(path, Path.extname(path))
  end

  def create(%document_type{} = document, opts \\ []) do
    with {:ok, typed_document} <-
           document
           |> init_document()
           |> document_type.create_document(),
         {:ok, created_document} <-
           create_file_from_template(typed_document, opts) do
      Vault.index(created_document)
      Loader.load(created_document)
    end
  end

  defp init_document(document) do
    document
    |> init_created_at()
    |> init_tags()
  end

  def init_created_at(%_{created_at: nil} = document) do
    %{document | created_at: DateTime.utc_now()}
  end

  def init_created_at(document), do: document

  defp init_tags(%_{tags: nil} = document) do
    %{document | tags: :magma |> Application.get_env(:default_tags) |> List.wrap()}
  end

  defp init_tags(document), do: document

  @doc false
  def init_path(%document_type{} = document) do
    case apply(document_type, :build_path, [document]) do
      # TODO: check consistency with existing path and name values?
      {:ok, path} -> {:ok, %{document | path: path, name: name_from_path(path)}}
      {:error, _} = error -> error
      undefined -> raise "Undefined result: #{inspect(undefined)}"
    end
  end

  defp create_file_from_template(%document_type{} = document, opts) do
    Magma.MixHelper.create_file(
      document.path,
      document_type.template().render(document),
      opts
    )

    {:ok, document}
  end

  def recreate(%_document_type{} = document) do
    document
    |> reset_document()
    |> create(force: true)
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

    case String.split(content, ~r{^\# }m, parts: 2) do
      # no header found
      [_] -> content
      [_, stripped_content] -> "# " <> stripped_content
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

    if Code.ensure_loaded?(module) and function_exported?(module, :create_document, 1) do
      module
    end
  end
end

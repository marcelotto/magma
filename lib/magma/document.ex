defmodule Magma.Document do
  @moduledoc """
  A behavior for the different kinds of document types in Magma.

  Besides the callback definition, it provides shared fields and logic between
  all document types. Each document type defines additional fields for its
  specific tasks and a path scheme that determines where instances of this type
  are stored.

  Note, that in general the content under the YAML frontmatter of a document
  is not further interpreted.
  `Magma.DocumentStruct` allows to get the AST of a Markdown document.
  """

  alias Magma.{Vault, View, Prompt, PromptResult, Session}

  import Magma.Utils, only: [init_fields: 2]

  @type t ::
          Prompt.t()
          | PromptResult.t()
          | Session.t()

  @type type :: module

  @doc """
  Builds the path of a new document during its creation.

  The function will receive a struct created with the respective `new` function, which should
  have initialized all parts required for this path building step.
  """
  @callback build_path(t()) :: {:ok, Path.t()}

  @doc """
  The title of the document used in the initial top-level header of a document.
  """
  @callback title(t()) :: binary

  @doc """
  Document type specific logic when loading a document.

  Usually the document type specific fields of the YAML front matter of the document
  are extracted and interpreted here.
  """
  @callback load_document(t()) :: {:ok, t()} | {:error, any}

  @doc """
  Renders the document type specific fields as YAML front matter lines.
  """
  @callback render_front_matter(t()) :: binary | nil

  # The fields every document type implementing this behaviour gets.
  @fields [
    # the path of the document
    path: nil,
    # the name of the file (used for links)
    name: nil,
    # the raw text of the document without the YAML front matter
    content: nil,
    # the list of tags in `tags` field of the YAML front matter
    tags: nil,
    # the list of aliases in `aliases` field of the YAML front matter
    aliases: nil,
    # the list of aliases in `aliases` field of the YAML front matter
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

      @doc """
      Loads a document from the given `path` or `document`.

      If the loaded document is not of the proper document type an `Magma.InvalidDocumentType`
      exception is returned in an `:error` tuple.
      """
      def load(%__MODULE__{} = document), do: Document.Loader.load(document)
      def load(path), do: Document.Loader.load(__MODULE__, path)

      @doc """
      Loads a document from the given `path` or `document` and raises an exception in error cases.
      """
      def load!(document_or_path) do
        case load(document_or_path) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end

      @doc """
      Loads a document from the given Obsidian `link`, i.e. a string of the form `"[[name]]"`.

      If the referenced document is not of the proper document type an `Magma.InvalidDocumentType`
      exception is returned in an `:error` tuple.
      """
      def load_linked(link), do: Document.Loader.load_linked(__MODULE__, link)

      @impl true
      def render_front_matter(%__MODULE__{}), do: nil

      defoverridable render_front_matter: 1
    end
  end

  @doc !"""
       This function should be used by `create` implementations of a document type
       to initialize the fields of the document which aren't set already.
       """
  def init(%_document_type{} = document, fields \\ []) do
    init_fields(
      document,
      [
        created_at: now(),
        tags: Magma.Config.system(:default_tags),
        aliases: []
      ]
      |> Keyword.merge(fields)
    )
  end

  @doc !"""
       This function should be called by `new` implementations of a document type
       to initialize its `:path` and `:name` (using the `build_path/1` callback).
       """
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

  @doc !"""
       Creates the file for new document.

       Note that the preferred way of creating a document is to use the respective
       `create` function on the document type module, which will call this function.
       """
  def create(%_document_type{} = document, opts \\ []) do
    cond do
      Magma.CLI.FileOps.create_file(document.path, full_content(document), opts) ->
        Vault.index(document)

        {:ok, document}

      Keyword.get(opts, :ok_skipped, false) ->
        {:ok, document}

      true ->
        {:skipped, document}
    end
  end

  @doc """
  Saves the changes on a document.
  """
  def save(%_document_type{} = document, opts \\ []) do
    with :ok <- Magma.CLI.FileOps.save_file(document.path, full_content(document), opts) do
      {:ok, document}
    end
  end

  defp full_content(document) do
    render_front_matter(document) <> document.content
  end

  @doc !"Renders the document metadata fields as YAML front matter."
  def render_front_matter(%document_type{} = document) do
    """
    ---
    magma_type: #{type_name(document_type)}
    """ <>
      if document_specific_front_matter = document_type.render_front_matter(document) do
        """
        #{document_specific_front_matter}
        """
      else
        ""
      end <>
      ("""
       #{render_custom_metadata(document.custom_metadata)}
       created_at: #{document.created_at}
       tags: #{View.yaml_list(document.tags)}
       aliases: #{View.yaml_list(document.aliases)}
       ---
       """
       |> String.trim_leading())
  end

  defp render_custom_metadata(metadata) do
    Enum.map_join(metadata, "\n", fn
      {key, nil} -> "#{key}: "
      {key, value} when is_atom(value) -> "#{key}: #{value |> to_string() |> inspect()}"
      {key, value} -> "#{key}: #{inspect(value)}"
    end)
  end

  @doc !"""
       Returns the content of the document with any content before the initial header
       (which is usually used for document controls) stripped off.
       """
  def content_without_prologue(document) do
    content = document.content

    # an AST transformation would be better, but does an implicit normalization
    case String.split(content, ~r{^\#.*\n}m, parts: 2) do
      [_, stripped_content] -> String.trim(stripped_content)
      _ -> raise "invalid document #{document.path}: no title header found"
    end
  end

  @doc false
  def now, do: NaiveDateTime.local_now()

  @doc """
  Returns the document type name for the given document.

  ## Example

      iex> Magma.Document.type_name(Magma.Prompt)
      "Prompt"

      iex> Magma.Document.type_name(Magma.PromptResult)
      "PromptResult"

      iex> Magma.Document.type_name(Magma.Session)
      "Session"

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
  Returns the document type module for the given string.

  ## Example

      iex> Magma.Document.type("Prompt")
      Magma.Prompt

      iex> Magma.Document.type("Session")
      Magma.Session

      iex> Magma.Document.type("PromptResult")
      Magma.PromptResult

      iex> Magma.Document.type("Config.System")
      Magma.Config.System

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

  @doc """
  Returns if the given module is a document type module.
  """
  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :build_path, 1)
  end
end

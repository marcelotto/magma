defmodule Magma.Document do
  @type t :: Magma.Concept.t()

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
    created_by: nil,
    # additional YAML front matter
    custom_metadata: nil
  ]
  def fields, do: @fields

  @template_path :code.priv_dir(:magma) |> Path.join("templates")

  @callback dependency :: atom

  @callback new_document(t()) :: {:ok, t()} | {:error, any}

  @callback load_document(t()) :: {:ok, t()} | {:error, any}

  @callback create_document(t()) :: {:ok, t()} | {:error, any}

  @callback document_template(t()) :: Path.t()

  @callback build_path(t()) :: {:ok, Path.t()}

  alias Magma.Utils

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Document
      alias Magma.Document

      defstruct Magma.Document.fields() ++ unquote(additional_fields)

      @impl true
      def new_document(%__MODULE__{} = document), do: {:ok, document}

      @impl true
      def create_document(%__MODULE__{} = document), do: {:ok, document}

      def new(fields_or_dependency), do: Document.new(__MODULE__, fields_or_dependency)
      def new(dependency, fields), do: Document.new(__MODULE__, dependency, fields)

      def new!(fields_or_dependency) do
        case new(fields_or_dependency) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end

      def new!(dependency, fields) do
        case new(dependency, fields) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end

      def create(%__MODULE__{} = document), do: Document.create(document)

      def load(%__MODULE__{} = document), do: Document.load(document)
      def load(path), do: Document.load(__MODULE__, path)

      defoverridable new_document: 1,
                     create_document: 1
    end
  end

  def template(%document_type{} = document) do
    Path.join(@template_path, document_type.document_template(document))
  end

  def new(document_type, %_{} = dependency), do: new(document_type, dependency, [])

  def new(document_type, fields) do
    with {:ok, document} <-
           document_type
           |> struct(fields)
           |> document_type.new_document() do
      with_path(document)
    end
  end

  def new(document_type, %_{} = dependency, fields) do
    new(document_type, Keyword.put(fields, document_type.dependency(), dependency))
  end

  @doc false
  defp with_path(%document_type{} = document) do
    case apply(document_type, :build_path, [document]) do
      {:ok, path} -> {:ok, %{document | path: path, name: name_from_path(path)}}
      {:error, _} = error -> error
      undefined -> raise "Undefined result: #{inspect(undefined)}"
    end
  end

  defp name_from_path(path) do
    Path.basename(path, Path.extname(path))
  end

  def create(%document_type{} = document) do
    with {:ok, typed_document} <- document_type.create_document(document),
         {:ok, created_document} <- create_file_from_template(typed_document) do
      load(created_document)
    end
  end

  defp create_file_from_template(%_document_type{} = document) do
    assigns = [
      document: document
    ]

    with :ok <-
           document
           |> template()
           |> Magma.MixHelper.copy_template(document.path, assigns) do
      {:ok, document}
    end
  end

  def load(%document_type{path: path} = _document) do
    with {:ok, loaded_document} <- load(document_type, path) do
      {:ok, loaded_document}
    end
  end

  def load(path) when is_binary(path) do
    with {:ok, metadata, body} <- read(path),
         {:ok, document_type, metadata} <- extract_type(metadata),
         document =
           struct(document_type,
             path: path,
             name: name_from_path(path),
             content: body,
             custom_metadata: metadata
           ),
         {:ok, document} <-
           document
           |> load_front_matter_property(:tags, &{:ok, &1})
           |> load_front_matter_property(:aliases, &{:ok, &1})
           |> load_front_matter_property(:created_at, &to_datetime/1) do
      document_type.load_document(document)
    end
  end

  def load(document_type, path) do
    case load(path) do
      {:ok, %^document_type{}} = ok ->
        ok

      {:ok, %_unexpected_document_type{} = unexpected_loaded_document} ->
        {:error,
         "unexpected_loaded_document: expected #{inspect(document_type)}, but got #{inspect(unexpected_loaded_document)}"}

      {:error, _} = error ->
        error
    end
  end

  defp extract_type(metadata) do
    case Map.pop(metadata, :magma_type) do
      {nil, _} -> {:error, :magma_type_missing}
      {type, metadata} -> {:ok, Module.concat(Magma, type), metadata}
    end
  end

  @doc false
  def load_front_matter_property(document, property, fun) do
    load_front_matter_property(document, property, property, fun)
  end

  @doc false
  def load_front_matter_property(document, key, property, fun)

  def load_front_matter_property({:error, _} = error, _, _, _), do: error

  def load_front_matter_property({:ok, document}, key, property, fun),
    do: load_front_matter_property(document, key, property, fun)

  def load_front_matter_property(document, key, property, fun) do
    case Map.pop(document.custom_metadata, key) do
      {nil, _} ->
        {:ok, document}

      {value, metadata} ->
        with {:ok, value} <- fun.(value) do
          {:ok, struct(document, [{property, value}, custom_metadata: metadata])}
        end
    end
  end

  defp read(path) do
    with {:ok, metadata, body} <- YamlFrontMatter.parse_file(path) do
      {:ok, Utils.atomize_keys(metadata), body}
    end
  end

  defp to_datetime(string) do
    with {:ok, datetime, _} <- DateTime.from_iso8601(string) do
      {:ok, datetime}
    end
  end
end

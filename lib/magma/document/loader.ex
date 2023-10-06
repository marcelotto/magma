defmodule Magma.Document.Loader do
  @moduledoc false

  alias Magma.{Document, Vault, Utils, InvalidDocumentType}
  alias Magma.Document

  def load(%document_type{path: path} = _document) do
    load(document_type, path)
  end

  def load(name_or_path) when is_binary(name_or_path) do
    if path = Vault.document_path(name_or_path) do
      with {:ok, metadata, body} <- read(path),
           {:ok, document_type, metadata} <- extract_type(metadata),
           document =
             struct(document_type,
               path: path,
               name: Document.name_from_path(path),
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
    else
      {:error, "#{name_or_path} not found"}
    end
  end

  def load(document_type, path) do
    case load(path) do
      {:ok, %^document_type{}} = ok ->
        ok

      {:ok, %unexpected_document_type{}} ->
        {:error,
         InvalidDocumentType.exception(
           document: path,
           expected: document_type,
           actual: unexpected_document_type
         )}

      {:error, _} = error ->
        error
    end
  end

  def load_linked(types, link) when is_list(types) do
    name = Utils.extract_link_text(link)

    with {:ok, document_type} <- Vault.document_type(name) do
      if document_type in types do
        document_type.load(name)
      else
        {:error,
         InvalidDocumentType.exception(
           document: name,
           expected: [types],
           actual: document_type
         )}
      end
    end
  end

  def load_linked(type, link) do
    name = Utils.extract_link_text(link)

    case Vault.document_path(name) do
      nil -> {:error, Magma.DocumentNotFound.exception(document_type: type, name: name)}
      path -> type.load(path)
    end
  end

  defp extract_type(metadata) do
    case Map.pop(metadata, :magma_type) do
      {nil, _} -> {:error, :magma_type_missing}
      {magma_type, metadata} -> {:ok, Document.type(magma_type), metadata}
    end
  end

  def load_front_matter_property(document, property, fun) do
    load_front_matter_property(document, property, property, fun)
  end

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
    NaiveDateTime.from_iso8601(string)
  end
end

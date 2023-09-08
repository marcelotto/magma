defmodule Magma.Vault do
  alias Magma.{Document, Concept, Artefact, Matter}
  alias Magma.Vault.Index

  @default_path "docs.magma"
  @concept_path_prefix "concepts"
  @artefact_path_prefix "artefacts"
  @artefact_generation_path_prefix Path.join(@artefact_path_prefix, "generated")
  @artefact_version_path_prefix Path.join(@artefact_path_prefix, "final")

  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  def concept_path(segments \\ nil), do: path([@concept_path_prefix | List.wrap(segments)])

  def artefact_generation_path(segments \\ nil),
    do: path([@artefact_generation_path_prefix | List.wrap(segments)])

  def artefact_version_path(segments \\ nil),
    do: path([@artefact_version_path_prefix | List.wrap(segments)])

  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync

  defdelegate index(document), to: Magma.Vault.Index, as: :add

  def document_path(name_or_path) do
    if File.exists?(name_or_path) do
      name_or_path
    else
      Index.get_document_path(name_or_path)
    end
  end

  def document_type(name_or_path) do
    path = document_path(name_or_path)
    {:ok, metadata, _body} = YamlFrontMatter.parse_file(path)
    magma_type = metadata["magma_type"]

    case Document.type(magma_type) do
      nil ->
        {:error, "invalid magma_type in #{path}: #{inspect(magma_type)}"}

      Concept ->
        magma_matter_type = metadata["magma_matter_type"]

        if matter_module = Matter.type(magma_matter_type) do
          {:ok, Concept, matter_module}
        else
          {:error, "invalid magma_matter_type in #{path}: #{inspect(magma_matter_type)}"}
        end

      Artefact.Prompt ->
        magma_artefact = metadata["magma_artefact"]

        if artefact_type = Artefact.type(magma_artefact) do
          {:ok, Artefact.Prompt, artefact_type}
        else
          {:error, "invalid magma_artefact in #{path}: #{inspect(artefact_type)}"}
        end
    end
  end
end

defmodule Magma.Vault do
  @default_path "docs.magma"
  @concept_path_prefix "__concepts__"
  @artefact_path_prefix "__artefacts__"

  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  def concept_path(segments \\ nil), do: path([@concept_path_prefix | List.wrap(segments)])
  def artefact_path(segments \\ nil), do: path([@artefact_path_prefix | List.wrap(segments)])

  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync

  defdelegate document_path(name), to: Magma.Vault.Index, as: :get_document_path
  defdelegate index(document), to: Magma.Vault.Index, as: :add
end

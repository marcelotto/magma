defmodule Magma.Vault do
  @default_path "docs.magma"

  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()
  def path(segments), do: [path() | List.wrap(segments)] |> Path.join()

  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync
end

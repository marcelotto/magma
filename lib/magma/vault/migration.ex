defmodule Magma.Vault.Migration do
  alias Magma.Vault

  @magma_version_requirement "~> #{%Version{Magma.version() | patch: 0, pre: []}}"
  def magma_version_requirement, do: @magma_version_requirement

  def migrate(), do: Vault.Version.load() |> migrate()

  defp migrate(version_string) when is_binary(version_string) do
    with {:ok, version} <- Version.parse(version_string) do
      migrate(version)
    end
  end

  defp migrate(%Version{} = vault_version) do
    if Version.match?(vault_version, @magma_version_requirement) do
      :ok
    else
      with {:ok, version} <- do_migrate(vault_version),
           :ok <- Vault.Version.save(version) do
        migrate(version)
      end
    end
  end

  defp do_migrate(%Version{major: 0, minor: 1} = version),
    do: Vault.Migration.V0_2.migrate(version)
end

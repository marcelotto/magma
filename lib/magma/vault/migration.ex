defmodule Magma.Vault.Migration do
  @moduledoc """
  Migration of Magma vaults to be compatible with newer versions.

  This module implements the general migration logic for `Magma.Vault`s
  created with older versions of Magma, so they can be updated to work with
  a newer version. It provides functionality to check the vault's version
  against the required version and apply any necessary migrations, implemented
  dedicated modules for specific versions. This process is crucial for
  maintaining consistency and functionality as the Magma project evolves.
  """

  alias Magma.Vault

  def magma_version_requirement do
    "~> #{%Version{Magma.version() | patch: 0, pre: []}}"
  end

  @doc """
  Applies all necessary migrations to update the vault for a newer version of Magma.
  """
  def migrate(), do: Vault.Version.load() |> migrate()

  defp migrate(version_string) when is_binary(version_string) do
    with {:ok, version} <- Version.parse(version_string) do
      migrate(version)
    end
  end

  defp migrate(%Version{} = vault_version) do
    if Version.match?(vault_version, magma_version_requirement()) do
      :ok
    else
      with {:ok, version} <- do_migrate(vault_version),
           :ok <- Vault.Version.save(version) do
        migrate(version)
      end
    end
  end

  defp do_migrate(%Version{major: 0, minor: minor}) when minor < 3 do
    {:error,
     """
     Magma v0.3 removed the Matter/Artefact system and requires a fresh vault initialization.

     Your vault is at version 0.#{minor}.x which is incompatible with Magma v0.3.

     To migrate:
     1. Back up any custom content from your current vault
     2. Delete or rename the existing vault directory
     3. Run `magma init` (or `mix magma.vault.init`) to create a new vault
     4. Restore your backed-up content manually
     """}
  end
end

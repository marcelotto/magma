defmodule Magma.Vault.Initializer do
  alias Magma.Vault
  alias Magma.Vault.BaseVault

  def initialize(base_vault \\ nil, _opts \\ []) do
    base_vault |> BaseVault.path!() |> create_vault()
  end

  defp create_vault(base_vault) do
    vault_dest_dir = Vault.path()

    if File.exists?(vault_dest_dir) do
      {:error, :already_existing}
    else
      Mix.Generator.create_directory(vault_dest_dir)

      base_vault
      |> Path.join(".obsidian")
      |> copy_directory(vault_dest_dir)

      :ok
    end
  end

  defp copy_directory(source, target, _options \\ []) do
    cmd = "cp -Rv #{source} #{target}"
    Mix.shell().info(cmd)
    Mix.shell().cmd(cmd)
  end
end

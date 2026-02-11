defmodule Magma.Vault.BaseVault do
  @default_base_vault_path Path.join(:code.priv_dir(:magma), "base_vault")
  @default_obsidian_path Path.join([@default_base_vault_path, "default", ".obsidian"])

  @config_files %{
    shell_commands:
      Path.join([@default_obsidian_path, "plugins", "obsidian-shellcommands", "data.json"]),
    quickadd: Path.join([@default_obsidian_path, "plugins", "quickadd", "data.json"])
  }

  for {_key, path} <- @config_files do
    @external_resource path
  end

  @shell_commands_json File.read!(@config_files.shell_commands)
  @quickadd_json File.read!(@config_files.quickadd)

  @moduledoc """
  Utilities for interacting with predefined and custom base vaults.

  A base vault is a preconfigured Obsidian vault that serves as a template when
  initializing a new Magma vault.

  ## Creating a new base vault

  If you are looking to create a new base vault (either a local one or as a
  contribution to the Magma project), ensure you include the required plugins
  from the default base vault:

  - [Buttons](https://github.com/shabegom/buttons)
  - [Shell commands](https://github.com/Taitava/obsidian-shellcommands)
  - [QuickAdd](https://github.com/chhoumann/quickadd)
  - [Dataview](https://github.com/blacksmithgu/obsidian-dataview)
  - [Automatic Table of Contents](https://github.com/johansatge/obsidian-automatic-table-of-contents)

  Also, it's vital to copy the configurations of the Shell Commands and QuickAdd
  plugins, as they include the integration with the Magma CLI commands.

  ### Shell Commands (`#{Path.relative_to(@config_files.shell_commands, @default_base_vault_path)}`)

  ```json
  #{@shell_commands_json}
  ```

  ### QuickAdd (`#{Path.relative_to(@config_files.quickadd, @default_base_vault_path)}`)

  ```json
  #{@quickadd_json}
  ```
  """

  @default_theme :default

  @type theme :: atom

  @doc """
  Returns the path to a base vault.

  Either the atom name of one of the predefined base vault in the `priv/base_vault`
  directory of Magma can be used or the path to a custom local base vault.
  If no base vault is given the default base vault is used.

      # Get path for the default base vault
      Magma.Vault.BaseVault.path()

      # Get path for a predefined base vault
      Magma.Vault.BaseVault.path(:custom_theme)

      # Get path for a custom base vault
      Magma.Vault.BaseVault.path("/path/to/custom/base/vault")

  """
  def path(path_or_theme \\ nil)
  def path(nil), do: path(@default_theme)
  def path(theme) when is_atom(theme), do: Path.join(base_vault_path(), to_string(theme))
  def path(path) when is_binary(path), do: path

  defp base_vault_path, do: :code.priv_dir(:magma) |> Path.join("base_vault")

  @doc """
  Returns the path to a base vault after validating that it exists.

  Accepts the same arguments as `path/1`.
  """
  def validated_path(path_or_theme \\ nil) do
    path = path(path_or_theme)

    if File.exists?(path) do
      {:ok, path}
    else
      {:error, "No base vault found at #{path}"}
    end
  end
end

defmodule Magma.Vault.BaseVault do
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

  Also, it's vital to copy the configurations of the Shell Commands and QuickAdd
  plugins, as they include the integration with the Magma CLI commands.
  """

  @path :code.priv_dir(:magma) |> Path.join("base_vault")
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
  def path(theme) when is_atom(theme), do: Path.join(@path, to_string(theme))
  def path(path) when is_binary(path), do: path

  @doc """
  Returns the path to a base vault and raises an error when the given base vault does not exist.

  Accepts the same arguments as `path/1`.
  """
  def path!(path_or_theme \\ nil) do
    path = path(path_or_theme)

    if File.exists?(path) do
      path
    else
      raise "No base vault found at #{path}"
    end
  end
end

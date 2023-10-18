defmodule Magma.Vault.BaseVault do
  use Magma

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

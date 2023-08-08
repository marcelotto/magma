defmodule Magma.Vault.BaseVault do
  @path :code.priv_dir(:magma) |> Path.join("base_vault")
  @default_theme :default

  def path(path_or_theme \\ nil)
  def path(nil), do: path(@default_theme)
  def path(theme) when is_atom(theme), do: Path.join(@path, to_string(theme))
  def path(path) when is_binary(path), do: path

  def path!(path_or_theme \\ nil) do
    path = path(path_or_theme)

    if File.exists?(path) do
      path
    else
      raise "No base vault found at #{path}"
    end
  end
end

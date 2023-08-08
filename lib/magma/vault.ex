defmodule Magma.Vault do
  @default_path "docs.magma"

  def path, do: Application.get_env(:magma, :dir, @default_path)
  def path(segments), do: [path() | List.wrap(segments)] |> Path.join()
end

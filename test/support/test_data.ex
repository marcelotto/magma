defmodule Magma.TestData do
  @moduledoc """
  Functions for accessing test data.
  """

  @path Path.join([File.cwd!(), "test", "data"])
  @vault_dir "example_vault"

  def path, do: @path

  def path(segments) when is_list(segments), do: segments |> Path.join() |> path()

  def path(name) do
    path = Path.join(@path, name)

    if File.exists?(path) do
      path
    else
      raise "no test data at #{path} found"
    end
  end

  def vault_path(segments \\ nil) do
    [@vault_dir | List.wrap(segments)] |> path()
  end

  def clear_vault do
    File.rm_rf!(vault_path())
  end
end

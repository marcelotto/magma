defmodule Magma.TestData do
  @moduledoc """
  Functions for accessing test data.
  """

  @path Path.join([File.cwd!(), "test", "data"])

  def path, do: @path

  def path(segments) when is_list(segments), do: segments |> Path.join() |> path()
  def path(name), do: Path.join(@path, name)
end

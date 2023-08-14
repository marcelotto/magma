defmodule Magma.TestVault do
  @moduledoc """
  Functions for working with the test vault.
  """
  alias Magma.TestData

  @dir "example_vault"
  @src_documents_path TestData.path("documents")

  def path(segments \\ nil) do
    [@dir | List.wrap(segments)] |> TestData.path()
  end

  def clear do
    File.rm_rf!(path())
  end

  def add(path) do
    dest = path(path)

    dest
    |> Path.dirname()
    |> File.mkdir_p!()

    @src_documents_path
    |> Path.join(path)
    |> File.cp!(dest)

    dest
  end
end

defmodule Magma.Matter.Module do
  use Magma.Matter

  @type t :: %__MODULE__{}

  @path_prefix "modules"

  @impl true
  def new(name, args \\ [])

  def new(name, args) when is_binary(name) do
    Elixir
    |> Module.concat(name)
    |> super(args)
  end

  def new(name, args), do: super(name, args)

  @impl true
  def concept_path(%__MODULE__{name: module}) do
    [@path_prefix | context_segments(module)]
    |> Path.join()
    |> Path.join("#{inspect(module)}.md")
  end

  defp context_segments(module) do
    module |> Module.split() |> List.delete_at(-1)
  end
end

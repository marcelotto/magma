defmodule Magma.Matter.Module do
  use Magma.Matter

  import Magma.Utils.Guards

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

  def source_path(%__MODULE__{name: module}), do: source_path(module)

  def source_path(module) when maybe_module(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__info__, 1) do
      if source = module.__info__(:compile)[:source], do: to_string(source)
    end
  end

  def code(%__MODULE__{name: module}), do: code(module)

  def code(module) when maybe_module(module) do
    if source_path = source_path(module) do
      code(source_path)
    end
  end

  def code(path) when is_binary(path) do
    File.read!(path)
  end
end

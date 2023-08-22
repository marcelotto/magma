defmodule Magma.Matter.Project do
  use Magma.Matter

  @type t :: %__MODULE__{}

  alias Magma.Matter

  @impl true
  def concept_path(%__MODULE__{name: name}), do: "#{name}.md"

  def app_name, do: Mix.Project.config()[:app]

  def version, do: Mix.Project.config()[:version]

  def modules do
    with {:ok, modules} <- :application.get_key(app_name(), :modules) do
      Enum.map(modules, &Matter.Module.new(&1))
    end
  end
end

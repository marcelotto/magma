defmodule Magma.Matter.Project do
  use Magma.Matter

  @type t :: %__MODULE__{}

  alias Magma.{Matter, Concept}

  @impl true
  def concept_path(%__MODULE__{}), do: "Project.md"

  def default_concept_aliases(%__MODULE__{name: name}), do: ["#{name} project", "#{name}-project"]

  def app_name, do: Mix.Project.config()[:app]

  def version, do: Mix.Project.config()[:version]

  def concept, do: Concept.load!("Project")

  def modules do
    with {:ok, modules} <- :application.get_key(app_name(), :modules) do
      Enum.map(modules, &Matter.Module.new(&1))
    end
  end
end

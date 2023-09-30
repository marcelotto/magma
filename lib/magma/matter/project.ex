defmodule Magma.Matter.Project do
  use Magma.Matter

  @type t :: %__MODULE__{}

  alias Magma.{Matter, Concept}

  @impl true
  def artefacts, do: []

  @impl true
  def new(name: name), do: new(name)

  def new(name) do
    {:ok, %__MODULE__{name: name}}
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(_document_name, _document_title, metadata) do
    case Map.pop(metadata, :magma_matter_name) do
      {nil, _} ->
        {:error, "magma_matter_name with project name missing in Project document"}

      {matter_name, remaining} ->
        with {:ok, matter} <- new(matter_name) do
          {:ok, matter, remaining}
        end
    end
  end

  def render_front_matter(%__MODULE__{} = matter) do
    """
    #{super(matter)}
    magma_matter_name: #{matter.name}
    """
    |> String.trim_trailing()
  end

  @impl true
  def default_concept_aliases(%__MODULE__{name: name}), do: ["#{name} project", "#{name}-project"]

  @impl true
  def relative_base_path(_), do: ""

  @impl true
  def relative_concept_path(%__MODULE__{} = project), do: "#{concept_name(project)}.md"

  @impl true
  def concept_name(%__MODULE__{}), do: "Project"

  @impl true
  def concept_title(%__MODULE__{name: name}), do: "#{name} project"

  @impl true
  def default_description(%__MODULE__{name: name}, _) do
    """
    What is the #{name} project about?
    """
    |> String.trim_trailing()
    |> View.Helper.comment()
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the '#{name}' project"
  end

  def app_name, do: Mix.Project.config()[:app]

  def version, do: Mix.Project.config()[:version]

  def concept, do: Concept.load!("Project")

  def modules do
    with {:ok, modules} <- :application.get_key(app_name(), :modules) do
      Enum.map(modules, &Matter.Module.new!(&1))
    end
  end
end

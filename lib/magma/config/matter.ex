defmodule Magma.Config.Matter do
  use Magma.Config.Document, fields: [:matter_type]

  alias Magma.View

  @impl true
  def title(%__MODULE__{matter_type: matter_type}),
    do: "#{Magma.Matter.type_name(matter_type, false)} matter config"

  @impl true
  def build_path(%__MODULE__{matter_type: matter_type}),
    do: {:ok, Magma.Config.matter_path("#{name_by_type(matter_type)}.md")}

  def name_by_type(matter_type), do: "#{Magma.Matter.type_name(matter_type)}.config"

  def context_knowledge_transclusion(matter_type) do
    matter_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end

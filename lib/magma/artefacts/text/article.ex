defmodule Magma.Artefacts.Article do
  use Magma.Artefact, matter: Magma.Matter.Text.Section

  alias Magma.{Concept, Matter, View}

  @relative_base_dir "article"

  @impl true
  def default_name(%Concept{subject: %Matter.Text{}} = concept),
    do: "#{concept.name} (article)"

  def default_name(%Concept{subject: %Matter.Text.Section{}} = concept),
    do: "#{concept.name} (article section)"

  @impl true
  def relative_base_path(%__MODULE__{concept: %Concept{subject: %matter_type{} = matter}}) do
    matter
    |> matter_type.relative_base_path()
    |> Path.join(@relative_base_dir)
  end

  @impl true
  def relative_version_path(%__MODULE__{
        name: name,
        concept: %Concept{subject: %Matter.Text{} = text}
      }) do
    text
    |> Matter.Text.relative_base_path()
    |> Path.join("#{name}.md")
  end

  def relative_version_path(%__MODULE__{} = artefact), do: super(artefact)

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    do_system_prompt_task(concept, text_type)
  end

  def system_prompt_task(
        %Concept{subject: %Matter.Text.Section{main_text: %Matter.Text{type: text_type}}} =
          concept
      ) do
    do_system_prompt_task(concept, text_type)
  end

  defp do_system_prompt_task(%Concept{}, text_type) do
    text_type
    |> Magma.Config.text_type()
    |> View.transclude(Magma.Config.TextType.system_prompt_section_title())
  end

  @impl true
  def request_prompt_task_template_bindings(concept) do
    Matter.Text.request_prompt_task_template_bindings(concept) ++ super(concept)
  end
end

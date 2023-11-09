defmodule Magma.Artefacts.Article do
  # TODO: matter is too limited: the final artefact version of the Text matter (generated from the preview), also has this as an artefact
  use Magma.Artefact, matter: Magma.Matter.Text.Section

  alias Magma.{Concept, Matter}

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

  defp do_system_prompt_task(%Concept{} = concept, text_type) do
    text_type.system_prompt_task(concept)
  end

  @impl true
  def request_prompt_task(%Concept{
        subject: %Matter.Text.Section{
          name: section_name,
          main_text: %Matter.Text{name: text_name}
        }
      }) do
    """
    Your task is to write the section "#{section_name}" of "#{text_name}".
    """
    |> String.trim_trailing()
  end
end

defmodule Magma.Artefacts.Article do
  use Magma.Artefact, matter: Magma.Matter.Text.Section

  alias Magma.{Concept, Matter}

  @relative_base_dir "article"

  @impl true
  def relative_base_path(%Concept{subject: %matter_type{} = matter}) do
    matter
    |> matter_type.relative_base_path()
    |> Path.join(@relative_base_dir)
  end

  @impl true
  def relative_version_path(%Concept{subject: %Matter.Text{} = text} = concept) do
    text
    |> Matter.Text.relative_base_path()
    |> Path.join("#{name(concept)}.md")
  end

  def relative_version_path(concept), do: super(concept)

  @impl true
  def name(%Concept{subject: %Matter.Text{}} = concept), do: "'#{concept.name}' article"

  def name(%Concept{subject: %Matter.Text.Section{}} = concept),
    do: "'#{concept.name}' article section"

  @impl true
  def system_prompt(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    do_system_prompt(concept, text_type)
  end

  def system_prompt(
        %Concept{subject: %Matter.Text.Section{main_text: %Matter.Text{type: text_type}}} =
          concept
      ) do
    do_system_prompt(concept, text_type)
  end

  defp do_system_prompt(%Concept{} = concept, text_type) do
    text_type.system_prompt(concept)
  end

  @impl true
  def task_prompt(%Concept{
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

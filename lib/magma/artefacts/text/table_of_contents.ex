defmodule Magma.Artefacts.TableOfContents do
  use Magma.Artefact, matter: Magma.Matter.Text

  alias Magma.{Concept, Matter, Artefact}

  import Magma.Obsidian.View.Helper

  @impl true
  def name(concept), do: "#{concept.name} ToC"

  @impl true
  def system_prompt(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    text_type.system_prompt(concept)
  end

  @impl true
  def task_prompt(%Concept{} = concept) do
    """
    Your task is to write an outline of "#{concept.name}".

    Please provide the outline in the following format:

    ```markdown
    ## Title of the first section

    Abstract: Abstract of the introduction.

    ## Title of the next section

    Abstract: Abstract of the next section.

    ## Title of the another section

    Abstract: Abstract of the another section.
    ```

    #{comment("Please don't change the general structure of this outline format. The section generator relies on an outline with sections.")}
    """
    |> String.trim_trailing()
  end

  @impl true
  def relative_base_path(%Concept{subject: matter}) do
    Matter.Text.relative_base_path(matter)
  end
end

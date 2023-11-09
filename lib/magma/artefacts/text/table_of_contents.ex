defmodule Magma.Artefacts.TableOfContents do
  use Magma.Artefact, matter: Magma.Matter.Text

  alias Magma.{Concept, Matter, Artefact}

  import Magma.View

  @impl true
  def default_name(%Concept{subject: %Matter.Text{name: name}}), do: "#{name} ToC"

  def default_name(%Concept{subject: %Matter.Text.Section{main_text: main_text}}),
    do: "#{main_text.name} ToC"

  @impl true
  def version_prologue(%Artefact.Version{artefact: %__MODULE__{}}) do
    assemble_button()
  end

  def assemble_button do
    button("Assemble sections", "magma.text.assemble", color: "blue")
  end

  def assemble_callout(version) do
    """
    The sections were already assembled. If you want to reassemble, please use the following Mix task:

    ```sh
    mix magma.text.assemble "#{version.name}"
    ```

    It will ask you to confirm any overwrites of files with user-provided content.
    """
    |> String.trim_trailing()
    |> callout()
  end

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    text_type.system_prompt_task(concept)
  end

  @impl true
  def request_prompt_task(%Concept{} = concept) do
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
  def relative_base_path(%__MODULE__{concept: %Concept{subject: matter}}) do
    Matter.Text.relative_base_path(matter)
  end
end

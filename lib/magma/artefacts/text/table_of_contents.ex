defmodule Magma.Artefacts.TableOfContents do
  use Magma.Artefact, matter: Magma.Matter.Text

  alias Magma.{Concept, Matter, Artefact, View}

  @impl true
  def default_name(%Concept{subject: %Matter.Text{name: name}}), do: "#{name} ToC"

  def default_name(%Concept{subject: %Matter.Text.Section{main_text: main_text}}),
    do: "#{main_text.name} ToC"

  @impl true
  def version_prologue(%Artefact.Version{artefact: %__MODULE__{}}) do
    assemble_button()
  end

  def assemble_button do
    View.button("Assemble sections", "magma.text.assemble", color: "blue")
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
    |> View.callout()
  end

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{type: text_type}}) do
    text_type
    |> Magma.Config.text_type()
    |> View.transclude(Magma.Config.TextType.system_prompt_section_title())
  end

  @impl true
  def request_prompt_task_template_bindings(concept) do
    Matter.Text.request_prompt_task_template_bindings(concept) ++ super(concept)
  end

  @impl true
  def relative_base_path(%__MODULE__{concept: %Concept{subject: matter}}) do
    Matter.Text.relative_base_path(matter)
  end
end

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefacts.TableOfContents]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:49
tags: [magma-vault]
aliases: []
---

**Generated results**

```dataview
TABLE
	tags AS Tags,
	magma_generation_type AS Generator,
	magma_generation_params AS Params
WHERE magma_prompt = [[]]
```

Final version: [[ModuleDoc of Magma.Artefacts.TableOfContents]]

**Actions**

```button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
```
```button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
```
```button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
```
```button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
```

# Prompt for ModuleDoc of Magma.Artefacts.TableOfContents

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Artefacts.TableOfContents#Context knowledge|]]


## Request

![[Magma.Artefacts.TableOfContents#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefacts.TableOfContents` ![[Magma.Artefacts.TableOfContents#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
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

```

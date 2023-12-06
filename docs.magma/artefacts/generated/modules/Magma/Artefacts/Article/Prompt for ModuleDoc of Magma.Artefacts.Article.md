---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefacts.Article]]"
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

Final version: [[ModuleDoc of Magma.Artefacts.Article]]

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

# Prompt for ModuleDoc of Magma.Artefacts.Article

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Artefacts.Article#Context knowledge|]]


## Request

![[Magma.Artefacts.Article#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefacts.Article` ![[Magma.Artefacts.Article#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefacts.Article do
  # TODO: matter is too limited: the final artefact version of the Text matter (generated from the preview), also has this as an artefact
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

```

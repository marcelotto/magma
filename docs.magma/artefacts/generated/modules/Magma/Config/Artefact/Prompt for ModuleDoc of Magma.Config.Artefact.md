---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.Artefact]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
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

Final version: [[ModuleDoc of Magma.Config.Artefact]]

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

# Prompt for ModuleDoc of Magma.Config.Artefact

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Config.Artefact#Context knowledge|]]


## Request

![[Magma.Config.Artefact#ModuleDoc prompt task|]]

### Description of the module `Magma.Config.Artefact` ![[Magma.Config.Artefact#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Config.Artefact do
  use Magma.Config.Document, fields: [:artefact_type]

  alias Magma.{DocumentStruct, View}
  alias Magma.DocumentStruct.Section

  @impl true
  def title(%__MODULE__{artefact_type: artefact_type}),
    do: "#{Magma.Artefact.type_name(artefact_type, false)} artefact config"

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title

  @task_prompt_section_title "Task prompt"
  def task_prompt_section_title, do: @task_prompt_section_title

  @impl true
  def build_path(%__MODULE__{artefact_type: artefact_type}),
    do: {:ok, Magma.Config.artefacts_path("#{name_by_type(artefact_type)}.md")}

  def name_by_type(artefact_type),
    do: "#{Magma.Artefact.type_name(artefact_type)}.artefact.config"

  def render_request_prompt(%__MODULE__{} = artefact_config, bindings) do
    artefact_config
    |> DocumentStruct.section_by_title(@task_prompt_section_title)
    |> Section.preserve_eex_tags()
    |> Section.to_markdown(header: false)
    |> String.trim()
    |> EEx.eval_string(bindings)
  end

  def context_knowledge_transclusion(artefact_type) do
    artefact_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end

```

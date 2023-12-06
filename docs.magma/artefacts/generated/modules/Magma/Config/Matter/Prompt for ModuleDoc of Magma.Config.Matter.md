---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.Matter]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: 2023-12-06 16:35:50
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

Final version: [[ModuleDoc of Magma.Config.Matter]]

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

# Prompt for ModuleDoc of Magma.Config.Matter

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Config.Matter#Context knowledge|]]


## Request

![[Magma.Config.Matter#ModuleDoc prompt task|]]

### Description of the module `Magma.Config.Matter` ![[Magma.Config.Matter#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Config.Matter do
  use Magma.Config.Document, fields: [:matter_type]

  alias Magma.View

  @impl true
  def title(%__MODULE__{matter_type: matter_type}),
    do: "#{Magma.Matter.type_name(matter_type, false)} matter config"

  @impl true
  def build_path(%__MODULE__{matter_type: matter_type}),
    do: {:ok, Magma.Config.matter_path("#{name_by_type(matter_type)}.md")}

  def name_by_type(matter_type), do: "#{Magma.Matter.type_name(matter_type)}.matter.config"

  def context_knowledge_transclusion(matter_type) do
    matter_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end

```

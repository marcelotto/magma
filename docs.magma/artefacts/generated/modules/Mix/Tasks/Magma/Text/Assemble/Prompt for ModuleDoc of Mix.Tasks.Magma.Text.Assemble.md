---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.Assemble]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:43
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Text.Assemble]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Text.Assemble

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Mix.Tasks.Magma.Text.Assemble#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Text.Assemble#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Text.Assemble` ![[Mix.Tasks.Magma.Text.Assemble#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Text.Assemble do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Text.Assembler

  @shortdoc "Generates the documents for the sections of a text"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> error("concept or toc name missing")
      opts, [document_name] -> Assembler.assemble(document_name, opts) |> handle_error()
    end)
  end
end

```

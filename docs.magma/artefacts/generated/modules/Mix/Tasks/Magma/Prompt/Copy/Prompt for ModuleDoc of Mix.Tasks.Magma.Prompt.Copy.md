---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Copy]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:47
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Copy]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Copy

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Mix.Tasks.Magma.Prompt.Copy#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Prompt.Copy#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Prompt.Copy` ![[Mix.Tasks.Magma.Prompt.Copy#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Prompt.Copy do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Document.Loader
  alias Magma.Prompt.Assembler

  @shortdoc "Copies the given prompt in compiled form to the clipboard"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt name or path missing")

      _opts, [prompt_name] ->
        prompt_name
        |> Loader.with_prompt(&Assembler.copy_to_clipboard/1)
        |> handle_error()
    end)
  end
end

```

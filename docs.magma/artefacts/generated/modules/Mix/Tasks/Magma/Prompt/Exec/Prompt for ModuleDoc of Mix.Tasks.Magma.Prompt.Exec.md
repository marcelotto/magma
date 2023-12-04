---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Exec]]"
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Exec]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Exec

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Mix.Tasks.Magma.Prompt.Exec#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Prompt.Exec#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Prompt.Exec` ![[Mix.Tasks.Magma.Prompt.Exec#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Prompt.Exec do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Generation, PromptResult}
  alias Magma.Document.Loader

  @shortdoc "Executes a prompt"

  # TODO: add Magma.Generation options
  @options [
    manual: :boolean,
    interactive: :boolean,
    trim_header: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt name or path missing")

      opts, [prompt_name] ->
        {attrs, opts} =
          case Keyword.pop(opts, :manual, false) do
            {true, opts} -> {[generation: Generation.Manual.new!()], opts}
            {_, opts} -> {[], opts}
          end

        prompt_name
        |> Loader.with_prompt(&PromptResult.create(&1, attrs, opts))
        |> handle_error()
    end)
  end
end

```

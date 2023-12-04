---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Gen]]"
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Gen]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Gen

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Mix.Tasks.Magma.Prompt.Gen#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Prompt.Gen#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Prompt.Gen` ![[Mix.Tasks.Magma.Prompt.Gen#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Prompt.Gen do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Prompt, Concept}

  @shortdoc "Generates a custom prompt or artefact prompt document"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("artefact type missing")

      _opts, [concept_name, artefact_type] ->
        if artefact_module = Artefact.type(artefact_type) do
          with {:ok, concept} <- Concept.load(concept_name),
               {:ok, _} <- Artefact.Prompt.create(concept, artefact_module) do
            :ok
          else
            error -> handle_error(error)
          end
        else
          error("unknown artefact type: #{artefact_type}")
        end

      _opts, [prompt_name] ->
        Prompt.create(prompt_name)
        |> handle_error()
    end)
  end
end

```

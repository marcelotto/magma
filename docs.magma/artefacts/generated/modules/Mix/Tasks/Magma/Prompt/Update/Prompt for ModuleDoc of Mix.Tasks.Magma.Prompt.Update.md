---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Update]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:46
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Update]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Update

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Mix.Tasks.Magma.Prompt.Update#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Prompt.Update#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Prompt.Update` ![[Mix.Tasks.Magma.Prompt.Update#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Prompt.Update do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Document, Vault}

  @shortdoc "Regenerates a artefact prompt"

  @options [
    all: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      [all: true], [] -> update_all()
      _opts, [] -> error("prompt name or path missing")
      _opts, [prompt_name] -> update(prompt_name)
    end)
  end

  def update_all do
    Enum.each(all_prompt_files(), &update/1)
  end

  def update(name) do
    with {:ok, prompt} <- Artefact.Prompt.load(name),
         {:ok, _} <- Document.recreate(prompt) do
      :ok
    end
    |> handle_error()
  end

  def all_prompt_files(path \\ Vault.artefact_generation_path()) do
    path
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      path = Path.join(path, entry)

      cond do
        entry == Magma.PromptResult.dir() -> []
        entry == Magma.Text.Preview.dir() -> []
        File.dir?(path) -> all_prompt_files(path)
        Path.extname(path) == ".md" -> [path]
        true -> []
      end
    end)
  end
end

```

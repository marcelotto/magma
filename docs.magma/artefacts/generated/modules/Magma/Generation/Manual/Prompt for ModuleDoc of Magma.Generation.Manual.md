---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Generation.Manual]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:55
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

Final version: [[ModuleDoc of Magma.Generation.Manual]]

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

# Prompt for ModuleDoc of Magma.Generation.Manual

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Generation.Manual#Context knowledge|]]


## Request

![[Magma.Generation.Manual#ModuleDoc prompt task|]]

### Description of the module `Magma.Generation.Manual` ![[Magma.Generation.Manual#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Generation.Manual do
  use Magma.Generation

  alias Magma.Prompt.Assembler

  import Magma.Utils.Guards

  defstruct []

  require Logger

  def new(description \\ nil) do
    {:ok, struct(__MODULE__, description: description)}
  end

  def new!(description \\ nil) do
    case new(description) do
      {:ok, manual} -> manual
      {:error, error} -> raise error
    end
  end

  @impl true
  def execute(%__MODULE__{}, prompt, opts \\ []) when is_prompt(prompt) do
    with {:ok, _} <- Assembler.copy_to_clipboard(prompt) do
      if Keyword.get(opts, :interactive, true) do
        {:ok, result_from_user()}
      else
        {:ok, ""}
      end
    end
  end

  defp result_from_user do
    """
    The prompt was copied to the clipboard.
    Please paste back the result of the manual execution and press Enter:
    """
    |> Mix.shell().prompt()
  end
end

```

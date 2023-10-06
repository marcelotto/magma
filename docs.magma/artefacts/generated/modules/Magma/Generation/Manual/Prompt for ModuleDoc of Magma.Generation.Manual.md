---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Generation.Manual]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:19
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

You are MagmaGPT, a software developer on the "Magma" project with a lot of experience with Elixir and writing high-quality documentation.

Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

```markdown
## Moduledoc

The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


## Function docs

In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

### `function/1`

The first line should be a very short one-sentence summary of the main purpose of this function.

Then follows the main body of the function documentation.
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]

##### `Magma.Generation` ![[Magma.Generation#Description|]]


## Request

### ![[Magma.Generation.Manual#ModuleDoc prompt task|]]

### Description of the module `Magma.Generation.Manual` ![[Magma.Generation.Manual#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Generation.Manual do
  @behaviour Magma.Generation

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
    Assembler.copy_to_clipboard(prompt)

    if Keyword.get(opts, :interactive, true) do
      {:ok, result_from_user()}
    else
      {:ok, ""}
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

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.New]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-11-02 20:16:34
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

Final version: [[ModuleDoc of Mix.Tasks.Magma.Text.New]]

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

# Prompt for ModuleDoc of Mix.Tasks.Magma.Text.New

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

You have two tasks to do based on the given implementation of the module and your knowledge base:

1. generate the content of the `@doc` strings of the public functions
2. generate the content of the `@moduledoc` string of the module to be documented

Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

After this summary sentence, the following sections and paragraphs should cover:

- What's the purpose of this module/function?
- For moduledocs: What are the main function(s) of this module?
- If possible, an example usage in an "Example" section using an indented code block
- configuration options (if there are any)
- everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

```markdown
## Function docs

### `function/1`

Summary sentence

Body

## Moduledoc

Summary sentence

Body
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

![[Mix.Tasks.Magma.Text.New#Context knowledge|]]


## Request

![[Mix.Tasks.Magma.Text.New#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Text.New` ![[Mix.Tasks.Magma.Text.New#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Text.New do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Text

  @shortdoc "Generates a new text concept"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> Mix.shell().error("text name missing")
      _opts, [text_name] -> create(text_name)
      _opts, [text_name, text_type_name] -> create(text_name, text_type_name)
    end)
  end

  defp create(text_name, text_type \\ nil) do
    text_name
    |> Text.create(text_type)
    |> handle_error()
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.Assemble]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:22
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


## Request

### ![[Mix.Tasks.Magma.Text.Assemble#ModuleDoc prompt task|]]

### Description of the module `Mix.Tasks.Magma.Text.Assemble` ![[Mix.Tasks.Magma.Text.Assemble#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Mix.Tasks.Magma.Text.Assemble do
  @shortdoc "Generates the section concepts from the final table of contents"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Concept, Artefact}
  alias Magma.Document.Loader
  alias Magma.Artefacts.TableOfContents
  alias Magma.Text.Assembler

  @options [
    force: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] -> Mix.shell().error("concept or toc name missing")
      opts, [concept_or_toc_name] -> assemble_toc!(concept_or_toc_name, opts)
    end)
  end

  defp assemble_toc!(concept_or_toc_name, opts) when is_binary(concept_or_toc_name) do
    with {:ok, document} <- Loader.load(concept_or_toc_name),
         {:ok, _} <- assemble_toc(document, opts) do
      :ok
    else
      {:error, error} -> raise error
    end
  end

  def assemble_toc(%Concept{} = concept, opts) do
    concept
    |> TableOfContents.load_version!()
    |> assemble_toc(opts)
  end

  def assemble_toc(%Artefact.Version{} = version, opts) do
    Assembler.assemble(version, opts)
  end

  def assemble_toc(%invalid_document_type{name: name}, _) do
    raise "#{name} has invalid document type #{inspect(invalid_document_type)}"
  end
end

```

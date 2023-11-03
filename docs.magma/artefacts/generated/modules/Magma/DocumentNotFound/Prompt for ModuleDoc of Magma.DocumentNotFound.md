---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.DocumentNotFound]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-06 16:03:18
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

Final version: [[ModuleDoc of Magma.DocumentNotFound]]

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

# Prompt for ModuleDoc of Magma.DocumentNotFound

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


## Request

### ![[Magma.DocumentNotFound#ModuleDoc prompt task|]]

### Description of the module `Magma.DocumentNotFound` ![[Magma.DocumentNotFound#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.DocumentNotFound do
  @moduledoc """
  Represents a missing document that is referenced somewhere.
  """
  defexception [:name, :document_type]

  def message(%{document_type: nil, name: name}) do
    "Document #{name} not found"
  end

  def message(%{document_type: document_type, name: name}) do
    "#{inspect(document_type)} document #{name} not found"
  end
end

defmodule Magma.InvalidDocumentType do
  @moduledoc """
  Raised when a document type does not match the expected one.
  """
  defexception [:document, :expected, :actual]

  def message(%{document: document, expected: expected, actual: actual}) do
    "invalid document type of #{document}: expected #{inspect(expected)}, but got #{inspect(actual)}"
  end
end

defmodule Magma.TopLevelEmptyHeaderTransclusionError do
  @moduledoc """
  Raised when an empty header transclusion on the outermost section is resolved,
  which is not supported, since it might expand to multiple sections and section-less content.
  """
  defexception []

  def message(_) do
    "empty header transclusions are not allowed on the top-level section"
  end
end

```

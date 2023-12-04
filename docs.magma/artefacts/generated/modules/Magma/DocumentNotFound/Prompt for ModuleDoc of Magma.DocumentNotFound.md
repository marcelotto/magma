---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.DocumentNotFound]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:49
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

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Magma.DocumentNotFound#Context knowledge|]]


## Request

![[Magma.DocumentNotFound#ModuleDoc prompt task|]]

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

```

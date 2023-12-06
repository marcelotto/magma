---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.Document]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: 2023-12-06 16:35:50
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

Final version: [[ModuleDoc of Magma.Config.Document]]

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

# Prompt for ModuleDoc of Magma.Config.Document

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Config.Document#Context knowledge|]]


## Request

![[Magma.Config.Document#ModuleDoc prompt task|]]

### Description of the module `Magma.Config.Document` ![[Magma.Config.Document#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Config.Document do
  @default_tags ["magma-config"]
  def default_tags, do: @default_tags

  @context_knowledge_section_title "Context knowledge"
  def context_knowledge_section_title, do: @context_knowledge_section_title

  defmacro __using__(opts) do
    additional_fields = [:sections | Keyword.get(opts, :fields, [])]

    quote do
      use Magma.Document, fields: unquote(additional_fields)

      @impl true
      @doc false
      def load_document(%__MODULE__{} = document) do
        with {:ok, document_struct} <- Magma.DocumentStruct.parse(document.content) do
          {:ok, %__MODULE__{document | sections: document_struct.sections}}
        end
      end

      defoverridable load_document: 1
    end
  end

  def init(document) do
    Magma.Document.init(document, tags: default_tags())
  end
end

```

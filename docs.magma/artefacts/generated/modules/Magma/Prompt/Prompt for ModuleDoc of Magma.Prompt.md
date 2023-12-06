---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Prompt]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:53
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

Final version: [[ModuleDoc of Magma.Prompt]]

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

# Prompt for ModuleDoc of Magma.Prompt

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Prompt#Context knowledge|]]


## Request

![[Magma.Prompt#ModuleDoc prompt task|]]

### Description of the module `Magma.Prompt` ![[Magma.Prompt#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Prompt do
  use Magma.Document, fields: [:generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Generation, PromptResult}
  alias Magma.Prompt.Template

  @path_prefix "custom_prompts"
  def path_prefix, do: @path_prefix

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{name: name}) do
    {:ok, [@path_prefix, name <> ".md"] |> Vault.path()}
  end

  @impl true
  def from(%__MODULE__{} = prompt), do: prompt
  def from(%PromptResult{prompt: %__MODULE__{}} = result), do: result.prompt

  def new(name, attrs \\ []) do
    struct(__MODULE__, Keyword.put(attrs, :name, name))
    |> Document.init_path()
  end

  def new!(name, attrs \\ []) do
    case new(name, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(name, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document
    |> Document.init(generation: Generation.default())
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(ArgumentError, "Magma.Prompt.create/3 is available only with an initialized document")

  def create(name, attrs, opts) do
    with {:ok, document} <- new(name, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%{generation: generation}) do
    Generation.render_front_matter(generation)
  end

  def render(%__MODULE__{} = prompt) do
    %__MODULE__{prompt | content: Template.render(prompt, Magma.Config.project())}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt) do
    with {:ok, generation, metadata} <- Generation.extract_from_metadata(prompt.custom_metadata) do
      {:ok,
       %__MODULE__{
         prompt
         | generation: generation,
           custom_metadata: metadata
       }}
    end
  end
end

```

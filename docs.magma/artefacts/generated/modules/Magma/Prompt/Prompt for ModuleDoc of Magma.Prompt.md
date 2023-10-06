---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Prompt]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:20
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

##### `Magma.Prompt.Template` ![[Magma.Prompt.Template#Description|]]


## Request

### ![[Magma.Prompt#ModuleDoc prompt task|]]

### Description of the module `Magma.Prompt` ![[Magma.Prompt#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Prompt do
  use Magma.Document, fields: [:generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Generation, PromptResult, View}
  alias Magma.Matter.Project
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
    |> Document.init(generation: Generation.default().new!())
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
    """
    magma_generation_type: #{inspect(Generation.short_name(generation))}
    magma_generation_params: #{View.yaml_nested_map(generation)}
    """
    |> String.trim_trailing()
  end

  def render(%__MODULE__{} = prompt) do
    %__MODULE__{prompt | content: Template.render(prompt, Project.concept())}
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

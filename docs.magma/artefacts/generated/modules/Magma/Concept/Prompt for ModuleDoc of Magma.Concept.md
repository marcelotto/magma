---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Concept]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
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

Final version: [[ModuleDoc of Magma.Concept]]

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

# Prompt for ModuleDoc of Magma.Concept

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

##### `Magma.Concept.Template` ![[Magma.Concept.Template#Description|]]


## Request

### ![[Magma.Concept#ModuleDoc prompt task|]]

### Description of the module `Magma.Concept` ![[Magma.Concept#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Concept do
  use Magma.Document,
    fields: [
      # the thing the concept is about
      :subject,
      # the content of the first level 1 header
      :title,
      # AST of the text before the title header
      :prologue,
      # ASTs of the sections
      :sections
    ]

  alias Magma.{Vault, Matter, DocumentStruct, Artefact, PromptResult}
  alias Magma.Concept.Template

  @type t :: %__MODULE__{}

  @description_section_title "Description"
  def description_section_title, do: @description_section_title

  @context_knowledge_section_title "Context knowledge"
  def context_knowledge_section_title, do: @context_knowledge_section_title

  @impl true
  def title(%__MODULE__{subject: %matter_type{} = matter}) do
    matter_type.concept_title(matter)
  end

  @impl true
  def build_path(%__MODULE__{subject: matter}), do: build_path(matter)

  def build_path(%matter_type{} = matter) do
    {:ok, matter |> matter_type.relative_concept_path() |> Vault.concept_path()}
  end

  @impl true
  def from(%__MODULE__{} = concept), do: concept
  def from(%Artefact.Prompt{} = prompt), do: prompt.concept
  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result), do: result.prompt.concept
  def from(%Artefact.Version{} = version), do: version.concept

  def new(subject, attrs \\ []) do
    struct(__MODULE__, [{:subject, subject} | attrs])
    |> Document.init_path()
  end

  def new!(subject, attrs \\ []) do
    case new(subject, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(subject, attrs \\ [], opts \\ [])

  def create(%__MODULE__{subject: %matter_type{} = matter} = document, opts, []) do
    {assigns, opts} = Keyword.pop(opts, :assigns, [])

    with {:ok, document} <-
           document
           |> Document.init(aliases: matter_type.default_concept_aliases(matter))
           |> render(assigns) do
      Document.create(document, opts)
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Concept.create/3 is available only with an initialized document"
      )

  def create(subject, attrs, opts) do
    with {:ok, document} <- new(subject, attrs) do
      create(document, opts)
    end
  end

  def create!(subject, attrs \\ [], opts \\ []) do
    case create(subject, attrs, opts) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{subject: %matter_type{} = matter}) do
    matter_type.render_front_matter(matter)
  end

  def render(%__MODULE__{} = concept, assigns) do
    %__MODULE__{concept | content: Template.render(concept, assigns)}
    |> parse()
  end

  defp parse(concept) do
    with {:ok, document_struct} <- DocumentStruct.parse(concept.content) do
      {:ok,
       %__MODULE__{
         concept
         | title: DocumentStruct.title(document_struct),
           prologue: document_struct.prologue,
           sections: document_struct.sections
       }}
    end
  end

  def update_content_from_ast(%__MODULE__{} = concept) do
    %__MODULE__{concept | content: DocumentStruct.to_string(concept)}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = concept) do
    with {:ok, concept} <- parse(concept),
         {:ok, matter, custom_metadata} <-
           Matter.extract_from_metadata(concept.name, concept.title, concept.custom_metadata) do
      {:ok, %__MODULE__{concept | subject: matter, custom_metadata: custom_metadata}}
    end
  end

  defdelegate fetch(concept, key), to: DocumentStruct

  def description_section(%__MODULE__{} = concept),
    do: get_in(concept, [concept.title, @description_section_title])

  def context_knowledge_section(%__MODULE__{} = concept),
    do: concept[@context_knowledge_section_title]
end

```

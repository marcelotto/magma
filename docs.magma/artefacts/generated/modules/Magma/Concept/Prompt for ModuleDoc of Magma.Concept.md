---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Concept]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-11-02 22:24:22
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

##### `Magma` ![[Magma#Description|]]

##### `Magma.Concept.Template` ![[Magma.Concept.Template#Description|]]

![[Magma.Concept#Context knowledge|]]


## Request

![[Magma.Concept#ModuleDoc prompt task|]]

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

  import Magma.Utils

  @type t :: %__MODULE__{}

  @default_artefacts :all

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
    with {:ok, document} <-
           document
           |> Document.init(aliases: matter_type.default_concept_aliases(matter))
           |> render(opts),
         {:ok, document} <- Document.create(document, opts),
         {:ok, _prompts} <- create_prompts(document, opts) do
      {:ok, document}
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

  def render(%__MODULE__{} = concept, opts) do
    with {:ok, artefact_types} <- artefacts(concept, opts) do
      assigns = Keyword.get(opts, :assigns, [])

      %__MODULE__{concept | content: Template.render(concept, artefact_types, assigns)}
      |> parse()
    end
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

  @spec update_content_from_ast(t()) :: t()
  def update_content_from_ast(%__MODULE__{} = concept) do
    %__MODULE__{concept | content: DocumentStruct.to_markdown(concept)}
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

  def create_prompts(%__MODULE__{} = concept, opts \\ []) do
    opts =
      if Keyword.has_key?(opts, :prompts) do
        Keyword.put(opts, :artefacts, Keyword.get(opts, :prompts))
      else
        opts
      end
      |> Keyword.put_new(:force, true)

    with {:ok, artefact_types} <- artefacts(concept, opts) do
      map_while_ok(artefact_types, & &1.create_prompt(concept, [], opts))
    end
  end

  defp artefacts(%__MODULE__{subject: %matter_type{}}, opts) when is_list(opts) do
    artefacts(matter_type, Keyword.get(opts, :artefacts, @default_artefacts))
  end

  defp artefacts(matter_type, true), do: artefacts(matter_type, :all)
  defp artefacts(matter_type, false), do: artefacts(matter_type, [])
  defp artefacts(matter_type, nil), do: artefacts(matter_type, [])
  defp artefacts(matter_type, :all), do: {:ok, matter_type.artefacts()}

  defp artefacts(matter_type, artefacts) do
    compatible_artefact_types = matter_type.artefacts()

    artefacts
    |> List.wrap()
    |> map_while_ok(fn artefact_type ->
      cond do
        not Artefact.type?(artefact_type) ->
          {:error, "invalid artefact type: #{inspect(artefact_type)}"}

        artefact_type not in compatible_artefact_types ->
          {:error,
           "artefact type #{inspect(artefact_type)} is not compatible with matter type #{inspect(matter_type)}"}

        true ->
          {:ok, artefact_type}
      end
    end)
  end
end

```

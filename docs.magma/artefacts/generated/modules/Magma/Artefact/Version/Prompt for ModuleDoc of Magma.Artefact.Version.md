---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefact.Version]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:17
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

Final version: [[ModuleDoc of Magma.Artefact.Version]]

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

# Prompt for ModuleDoc of Magma.Artefact.Version

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

##### `Magma.Artefact` ![[Magma.Artefact#Description|]]


## Request

### ![[Magma.Artefact.Version#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefact.Version` ![[Magma.Artefact.Version#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:artefact, :concept, :draft]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, PromptResult, DocumentStruct, View}
  alias Magma.DocumentStruct.Section
  alias Magma.Document.Loader
  alias Magma.Text.Preview

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    build_path(concept, artefact)
  end

  def build_path(concept, artefact) do
    {:ok, concept |> artefact.relative_version_path() |> Vault.artefact_version_path()}
  end

  @impl true
  def from(%__MODULE__{} = version), do: version
  def from({%Concept{} = concept, artefact}), do: artefact.name(concept)

  def from(%Artefact.Prompt{} = prompt),
    do: from({Concept.from(prompt), prompt.artefact})

  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result),
    do: from({Concept.from(result), result.prompt.artefact})

  def new(draft, attrs \\ [])

  def new(%PromptResult{prompt: %Artefact.Prompt{}} = prompt_result, attrs) do
    attrs =
      attrs
      |> Keyword.put_new(:concept, prompt_result.prompt.concept)
      |> Keyword.put_new(:artefact, prompt_result.prompt.artefact)

    cond do
      attrs[:concept] != prompt_result.prompt.concept -> {:error, "inconsistent concept"}
      attrs[:artefact] != prompt_result.prompt.artefact -> {:error, "inconsistent artefact"}
      true -> do_new(prompt_result, attrs)
    end
  end

  def new(%Preview{} = preview, attrs) do
    attrs =
      attrs
      |> Keyword.put_new(:concept, preview.concept)
      |> Keyword.put_new(:artefact, preview.artefact)

    cond do
      attrs[:concept] != preview.concept -> {:error, "inconsistent concept"}
      attrs[:artefact] != preview.artefact -> {:error, "inconsistent artefact"}
      true -> do_new(preview, attrs)
    end
  end

  def new(%Magma.DocumentNotFound{} = missing_document, attrs) do
    cond do
      !attrs[:concept] -> {:error, "concept missing"}
      !attrs[:artefact] -> {:error, "artefact missing"}
      true -> do_new(missing_document, attrs)
    end
  end

  defp do_new(draft, attrs) do
    struct(__MODULE__, [{:draft, draft} | attrs])
    |> Document.init_path()
  end

  def new!(draft, attrs \\ []) do
    case new(draft, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(draft, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init()
           |> assemble() do
      Document.create(document, opts)
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Version.create/3 is available only with new/2 arguments"
      )

  def create(draft, attrs, opts) do
    with {:ok, document} <- new(draft, attrs) do
      create(document, opts)
    end
  end

  defp assemble(%__MODULE__{draft: %PromptResult{}} = document) do
    content =
      """
      # #{title(document)}

      #{Document.content_without_prologue(document.draft)}
      """

    {:ok, %__MODULE__{document | content: prologue(document) <> content}}
  end

  defp assemble(%__MODULE__{draft: %Preview{}} = document) do
    with {:ok, document_struct} <- DocumentStruct.parse(document.draft.content) do
      content =
        document_struct
        |> DocumentStruct.main_section()
        |> Section.resolve_transclusions()
        |> Section.remove_comments()
        |> Section.to_string()

      {:ok, %__MODULE__{document | content: prologue(document) <> content}}
    end
  end

  defp prologue(%__MODULE__{artefact: artefact} = version) do
    if prologue = artefact.version_prologue(version) do
      """

      #{prologue}

      """
    else
      ""
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    magma_artefact: #{Magma.Artefact.type_name(document.artefact)}
    magma_concept: "#{View.link_to(document.concept)}"
    magma_draft: "#{View.link_to(document.draft)}"
    """
    |> String.trim_trailing()
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = version) do
    {draft_link, metadata} = Map.pop(version.custom_metadata, :magma_draft)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)
    {artefact_type, metadata} = Map.pop(metadata, :magma_artefact)

    cond do
      !draft_link ->
        {:error, "magma_draft missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      !artefact_type ->
        {:error, "magma_artefact missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, draft} <-
               (case Loader.load_linked([PromptResult, Preview], draft_link) do
                  {:ok, _} = ok -> ok
                  {:error, %Magma.DocumentNotFound{} = e} -> {:ok, e}
                end),
             {:ok, concept} <- Concept.load_linked(concept_link) do
          {:ok,
           %__MODULE__{
             version
             | artefact: artefact_module,
               concept: concept,
               draft: draft,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefact.Version]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:47
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

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Magma.Artefact.Version#Context knowledge|]]


## Request

![[Magma.Artefact.Version#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefact.Version` ![[Magma.Artefact.Version#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:artefact, :draft]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, PromptResult, DocumentStruct, View}
  alias Magma.DocumentStruct.Section
  alias Magma.Document.Loader
  alias Magma.Text.Preview

  @impl true
  def title(%__MODULE__{artefact: %artefact_type{}} = version),
    do: artefact_type.version_title(version)

  @impl true
  def build_path(%__MODULE__{artefact: artefact}) do
    build_path(artefact)
  end

  def build_path(%_artefact_type{} = artefact) do
    {:ok, artefact |> Artefact.relative_version_path() |> Vault.artefact_version_path()}
  end

  @impl true
  def from(%__MODULE__{} = version), do: version
  def from(%Artefact.Prompt{} = prompt), do: from(prompt.artefact)
  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result), do: from(result.prompt.artefact)
  def from(%Preview{} = preview), do: from(preview.artefact)
  def from(%_artefact_type{concept: _, name: name}), do: name

  def new(draft, attrs \\ [])

  def new(%PromptResult{prompt: %Artefact.Prompt{}} = prompt_result, attrs) do
    attrs = Keyword.put_new(attrs, :artefact, prompt_result.prompt.artefact)

    if attrs[:artefact] == prompt_result.prompt.artefact do
      do_new(prompt_result, attrs)
    else
      {:error, "inconsistent artefact"}
    end
  end

  def new(%Preview{} = preview, attrs) do
    attrs = Keyword.put_new(attrs, :artefact, preview.artefact)

    if attrs[:artefact] == preview.artefact do
      do_new(preview, attrs)
    else
      {:error, "inconsistent artefact"}
    end
  end

  def new(%Magma.DocumentNotFound{} = missing_document, attrs) do
    if attrs[:artefact] do
      do_new(missing_document, attrs)
    else
      {:error, "artefact missing"}
    end
  end

  defp do_new(draft, attrs) do
    __MODULE__
    |> struct(Keyword.put(attrs, :draft, draft))
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
      do_create(document, opts)
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Version.create/3 is not available with an initialized document"
      )

  def create(draft, attrs, opts) do
    with {:ok, document} <- new(draft, attrs) do
      create(document, opts)
    end
  end

  defp do_create(%__MODULE__{artefact: %artefact_type{}} = document, opts) do
    artefact_type.create_version(document, opts) ||
      Document.create(document, opts)
  end

  defp assemble(%__MODULE__{draft: %PromptResult{}} = document) do
    title = if title = title(document), do: "# #{title}"

    content =
      """
      #{title}

      #{Document.content_without_prologue(document.draft)}
      """
      |> String.trim_leading()

    {:ok, %__MODULE__{document | content: prologue(document) <> content}}
  end

  defp assemble(%__MODULE__{draft: %Preview{}} = document) do
    with {:ok, document_struct} <- DocumentStruct.parse(document.draft.content) do
      content =
        document_struct
        |> DocumentStruct.main_section()
        |> Section.resolve_transclusions()
        |> Section.remove_comments()
        |> Section.to_markdown()

      {:ok, %__MODULE__{document | content: prologue(document) <> content}}
    end
  end

  defp prologue(%__MODULE__{artefact: %artefact_type{}} = version) do
    if prologue = artefact_type.version_prologue(version) do
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
    #{Artefact.render_front_matter(document.artefact)}
    magma_draft: "#{View.link_to(document.draft)}"
    """
    |> String.trim_trailing()
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = version) do
    {draft_link, metadata} = Map.pop(version.custom_metadata, :magma_draft)

    if draft_link do
      with {:ok, artefact, metadata} <- Artefact.extract_from_metadata(metadata),
           {:ok, draft} <-
             (case Loader.load_linked([PromptResult, Preview], draft_link) do
                {:ok, _} = ok -> ok
                {:error, %Magma.DocumentNotFound{} = e} -> {:ok, e}
              end) do
        {:ok,
         %__MODULE__{
           version
           | artefact: artefact,
             draft: draft,
             custom_metadata: metadata
         }}
      end
    else
      {:error, "magma_draft missing"}
    end
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Text.Preview]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:21
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

Final version: [[ModuleDoc of Magma.Text.Preview]]

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

# Prompt for ModuleDoc of Magma.Text.Preview

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

##### `Magma.Text` ![[Magma.Text#Description|]]


## Request

### ![[Magma.Text.Preview#ModuleDoc prompt task|]]

### Description of the module `Magma.Text.Preview` ![[Magma.Text.Preview#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Text.Preview do
  use Magma.Document, fields: [:artefact, :concept]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Concept, Matter, Artefact, View}

  import Magma.Utils, only: [map_while_ok: 2]

  require Logger

  @impl true
  def title(%__MODULE__{} = preview), do: build_name(preview)

  def build_name(%__MODULE__{} = preview) do
    build_name(preview.artefact, preview.concept)
  end

  def build_name(artefact, %Concept{} = concept) do
    "#{artefact.name(concept)} Preview"
  end

  @impl true
  def from({%Concept{} = concept, artefact}), do: build_name(artefact, concept)
  def from(%__MODULE__{} = preview), do: preview

  @impl true
  def build_path(%__MODULE__{concept: text_concept} = preview) do
    {:ok,
     [
       Matter.Text.relative_base_path(text_concept.subject),
       "__previews__",
       "#{title(preview)}.md"
     ]
     |> Vault.artefact_generation_path()}
  end

  def new(%Concept{subject: %Matter.Text{}} = concept, artefact, attrs \\ []) do
    struct(__MODULE__, [{:artefact, artefact}, {:concept, concept} | attrs])
    |> Document.init_path()
  end

  def new!(concept, artefact, attrs \\ []) do
    case new(concept, artefact, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(concept, artefact, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, [], []) do
    with {:ok, document} <-
           document
           |> Document.init()
           |> render(),
         {:ok, document} <- Document.create(document, opts) do
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Preview.create/4 is available only with an initialized document"
      )

  def create(concept, artefact, attrs, opts) do
    with {:ok, document} <- new(concept, artefact, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    magma_artefact: #{Artefact.type_name(document.artefact)}
    magma_concept: "#{View.link_to(document.concept)}"
    """
    |> String.trim_trailing()
  end

  def render(%__MODULE__{} = preview) do
    with {:ok, content} <- render_from_toc(preview) do
      {:ok, %__MODULE__{preview | content: content}}
    end
  end

  defp render_from_toc(preview) do
    if section = preview.concept[Matter.Text.sections_section_title()] do
      with {:ok, toc} <-
             section
             |> extract_concept_toc()
             |> map_while_ok(&version_section_transclusion(preview, &1)) do
        {
          :ok,
          """
          #{prologue()}

          # #{title(preview)}

          #{Enum.join(toc, "\n\n")}
          """
        }
      end
    else
      {:error,
       "No '#{Matter.Text.sections_section_title()}' section found in #{preview.concept.path}"}
    end
  end

  def prologue do
    View.button("Finalize", "magma.text.finalize", color: "blue")
  end

  defp extract_concept_toc(section) do
    Enum.flat_map(section.sections, fn
      %Magma.DocumentStruct.Section{
        header: %Panpipe.AST.Header{
          children: [
            %Panpipe.AST.Link{},
            %Panpipe.AST.Space{},
            %Panpipe.AST.Image{target: target, title: "wikilink"}
          ]
        }
      } ->
        case String.split(target, "#", parts: 2) do
          [concept_name, _] -> [concept_name]
          [concept_name] -> [concept_name]
        end

      _ ->
        []
    end)
  end

  defp version_section_transclusion(preview, concept_name) do
    with {:ok, concept} <- Concept.load(concept_name) do
      {:ok,
       "## #{Concept.title(concept)} #{View.transclude_version({concept, preview.artefact}, :title)}"}
    end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = preview) do
    {artefact_type, metadata} = Map.pop(preview.custom_metadata, :magma_artefact)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)

    cond do
      !artefact_type ->
        {:error, "artefact_type missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, concept} <- Concept.load_linked(concept_link) do
          {:ok,
           %__MODULE__{
             preview
             | artefact: artefact_module,
               concept: concept,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

```

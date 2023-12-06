---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Text.Preview]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:54
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

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Text.Preview#Context knowledge|]]


## Request

![[Magma.Text.Preview#ModuleDoc prompt task|]]

### Description of the module `Magma.Text.Preview` ![[Magma.Text.Preview#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Text.Preview do
  use Magma.Document, fields: [:artefact]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Concept, Matter, Artefact, View}

  import Magma.Utils, only: [map_while_ok: 2]

  require Logger

  @dir "__previews__"
  def dir, do: @dir

  @impl true
  def title(%__MODULE__{} = preview), do: build_name(preview)

  def build_name(%__MODULE__{} = preview), do: build_name(preview.artefact)
  def build_name(%_artefact_type{name: name}), do: "#{name} Preview"

  @impl true
  def from(%__MODULE__{} = preview), do: preview
  def from(%_artefact_type{concept: _, name: _} = artefact), do: build_name(artefact)

  @impl true
  def build_path(%__MODULE__{artefact: artefact} = preview) do
    {:ok,
     [
       Matter.Text.relative_base_path(artefact.concept.subject),
       @dir,
       "#{title(preview)}.md"
     ]
     |> Vault.artefact_generation_path()}
  end

  def new(artefact, attrs \\ []) do
    __MODULE__
    |> struct(Keyword.put(attrs, :artefact, artefact))
    |> Document.init_path()
  end

  def new!(artefact, attrs \\ []) do
    case new(artefact, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(artefact, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init()
           |> render(),
         {:ok, document} <- Document.create(document, opts) do
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Preview.create/3 is not available with an initialized document"
      )

  def create(artefact, attrs, opts) do
    with {:ok, document} <- new(artefact, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    Artefact.render_front_matter(document.artefact)
  end

  def render(%__MODULE__{} = preview) do
    with {:ok, content} <- render_from_toc(preview) do
      {:ok, %__MODULE__{preview | content: content}}
    end
  end

  defp render_from_toc(preview) do
    if section = preview.artefact.concept[Matter.Text.sections_section_title()] do
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
       "No '#{Matter.Text.sections_section_title()}' section found in #{preview.artefact.concept.path}"}
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
    with {:ok, concept} <- Concept.load(concept_name),
         {:ok, section_artefact} <- preview.artefact.__struct__.new(concept) do
      {:ok, "## #{Concept.title(concept)} #{View.transclude_version(section_artefact, :title)}"}
    end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = preview) do
    with {:ok, artefact, metadata} <- Artefact.extract_from_metadata(preview.custom_metadata) do
      {:ok,
       %__MODULE__{
         preview
         | artefact: artefact,
           custom_metadata: metadata
       }}
    end
  end
end

```

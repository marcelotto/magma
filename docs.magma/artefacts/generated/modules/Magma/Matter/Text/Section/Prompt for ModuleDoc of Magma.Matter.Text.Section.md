---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Text.Section]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:48
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

Final version: [[ModuleDoc of Magma.Matter.Text.Section]]

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

# Prompt for ModuleDoc of Magma.Matter.Text.Section

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Magma.Matter.Text.Section#Context knowledge|]]


## Request

![[Magma.Matter.Text.Section#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Text.Section` ![[Magma.Matter.Text.Section#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Text.Section do
  use Magma.Matter, fields: [:main_text]

  alias Magma.Concept
  alias Magma.Matter.Text
  alias Magma.Artefacts.TableOfContents
  alias Magma.View

  require Logger

  @type t :: %__MODULE__{}

  @impl true
  def artefacts, do: [Magma.Artefacts.Article]

  @impl true
  def relative_base_path(%__MODULE__{main_text: main_text}) do
    Text.relative_base_path(main_text)
  end

  @impl true
  def relative_concept_path(%__MODULE__{} = section) do
    section
    |> relative_base_path()
    |> Path.join("#{concept_name(section)}.md")
  end

  @impl true
  def concept_name(%__MODULE__{name: name, main_text: main_text}) do
    "#{main_text.name} - #{name}"
  end

  @impl true
  def concept_title(%__MODULE__{name: name}), do: name

  @impl true
  def default_description(%__MODULE__{}, abstract: abstract), do: abstract

  @impl true
  def context_knowledge(
        %Concept{subject: %__MODULE__{main_text: %{type: type} = main_text}} = concept
      ) do
    """
    #{super(concept)}

    #{Magma.Config.TextType.context_knowledge_transclusion(type)}

    #### Outline of the '#{main_text.name}' content #{View.transclude(TableOfContents.default_name(concept), :title)}

    """ <>
      case Concept.load(main_text.name) do
        {:ok, text_concept} ->
          View.include_context_knowledge(text_concept)

        {:error, error} ->
          Logger.warning("error on main text context knowledge extraction: #{inspect(error)}")
          ""
      end
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the intended content of the '#{name}' section"
  end

  def new(attrs) when is_list(attrs) do
    # TODO: check presence of main_text
    {:ok, struct(__MODULE__, attrs)}
  end

  def new(main_text, name) do
    new(name: name, main_text: main_text)
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  def new!(main_text, name) do
    case new(main_text, name) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(_document_name, document_title, metadata) do
    {main_text_link, metadata} = Map.pop(metadata, :magma_section_of)

    if main_text_link do
      with {:ok, main_text_concept} <- Concept.load_linked(main_text_link),
           {:ok, matter} <- new(main_text_concept.subject, document_title) do
        {:ok, matter, metadata}
      end
    else
      {:error, "magma_section_of missing"}
    end
  end

  def render_front_matter(%__MODULE__{} = section) do
    """
    #{super(section)}
    magma_section_of: "#{View.link_to(section.main_text)}"
    """
    |> String.trim_trailing()
  end
end

```

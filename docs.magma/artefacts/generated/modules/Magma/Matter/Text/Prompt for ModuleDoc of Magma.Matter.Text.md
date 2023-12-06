---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Text]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:52
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

Final version: [[ModuleDoc of Magma.Matter.Text]]

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

# Prompt for ModuleDoc of Magma.Matter.Text

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Matter.Text#Context knowledge|]]


## Request

![[Magma.Matter.Text#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Text` ![[Magma.Matter.Text#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Text do
  use Magma.Matter, fields: [:type]

  alias Magma.{Matter, Concept}
  alias Magma.Matter.Text.Section

  @type t :: %__MODULE__{}
  @type type :: module

  @impl true
  def artefacts, do: [Magma.Artefacts.TableOfContents]

  @sections_section_title "Sections"
  def sections_section_title, do: @sections_section_title

  @relative_base_path "texts"
  @impl true
  def relative_base_path(%__MODULE__{} = text),
    do: Path.join(@relative_base_path, concept_name(text))

  @impl true
  def relative_concept_path(%__MODULE__{} = text) do
    text
    |> relative_base_path()
    |> Path.join("#{concept_name(text)}.md")
  end

  @impl true
  def concept_name(%__MODULE__{name: name}), do: name

  @impl true
  def concept_title(%__MODULE__{name: name}), do: name

  @impl true
  def default_description(%__MODULE__{name: name}, _) do
    """
    What should "#{name}" cover?
    """
    |> View.comment()
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the content to be covered by '#{name}'"
  end

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{type: type}} = concept) do
    """
    #{super(concept)}

    #{Magma.Config.TextType.context_knowledge_transclusion(type)}
    """
    |> String.trim_trailing()
  end

  @impl true
  def custom_concept_sections(%Concept{} = concept) do
    """

    # #{@sections_section_title}

    #{View.comment("Don't remove or edit this section! The results of the generated table of contents will be copied to this place.")}


    # Artefact previews

    """ <>
      Enum.map_join(
        Matter.Text.Section.artefacts(),
        "\n",
        &"- #{concept |> &1.new!() |> View.link_to_preview()}"
      )
  end

  @spec new(binary, keyword) :: {:ok, t()} | {:error, any}
  def new(name, attrs \\ []) do
    # TODO: validate type
    {:ok,
     struct(
       __MODULE__,
       attrs
       |> Keyword.put(:name, name)
       |> Keyword.put_new(:type, Magma.Matter.Texts.Generic)
     )}
  end

  def new!(name, attrs \\ []) do
    case new(name, attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @doc false
  def request_prompt_task_template_bindings(%Concept{subject: %__MODULE__{} = text}) do
    [
      text: text,
      section: nil
    ]
  end

  def request_prompt_task_template_bindings(%Concept{subject: %Section{} = section}) do
    [
      text: section.main_text,
      section: section
    ]
  end

  @impl true
  def extract_from_metadata(document_name, _document_title, metadata) do
    {magma_matter_text_type, remaining} = Map.pop(metadata, :magma_matter_text_type)

    cond do
      !magma_matter_text_type ->
        {:error, "magma_matter_text_type missing in #{document_name}"}

      text_type = type(magma_matter_text_type) ->
        with {:ok, matter} <- new(document_name, type: text_type) do
          {:ok, matter, remaining}
        end

      true ->
        {:error, "invalid magma_matter_text_type: #{magma_matter_text_type}"}
    end
  end

  def render_front_matter(%__MODULE__{} = text) do
    """
    #{super(text)}
    magma_matter_text_type: #{Magma.Matter.Text.type_name(text.type)}
    """
    |> String.trim_trailing()
  end

  @doc """
  Returns the text type name for the given text module.

  ## Example

      iex> Magma.Matter.Text.type_name(Magma.Matter.Texts.UserGuide)
      "UserGuide"

      iex> Magma.Matter.Text.type_name(Magma.Matter.Texts.Generic)
      "Generic"

      iex> Magma.Matter.Text.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Matter.Text type: Magma.Vault

      iex> Magma.Matter.Text.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Matter.Text type: NonExisting

  """
  def type_name(type, validate \\ true) do
    if not validate or type?(type) do
      case Module.split(type) do
        ["Magma", "Matter", "Texts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Matter.Text type: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Matter.Text type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the text type module for the given string.

  ## Example

      iex> Magma.Matter.Text.type("UserGuide")
      Magma.Matter.Texts.UserGuide

      iex> Magma.Matter.Text.type("Generic")
      Magma.Matter.Texts.Generic

      iex> Magma.Matter.Text.type("Vault")
      nil

      iex> Magma.Matter.Text.type("NonExisting")
      nil

  """
  def type(string, validate \\ true) when is_binary(string) do
    module = Module.concat(Magma.Matter.Texts, string)

    if not validate or type?(module) do
      module
    end
  end

  def type?(module) do
    module in Magma.Config.text_types()
  end
end

```

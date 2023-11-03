---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Text]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
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

##### `Magma.Matter` ![[Magma.Matter#Description|]]

##### `Magma.Matter.Text.Section` ![[Magma.Matter.Text.Section#Description|]]

##### `Magma.Matter.Text.Type` ![[Magma.Matter.Text.Type#Description|]]


## Request

### ![[Magma.Matter.Text#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Text` ![[Magma.Matter.Text#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Text do
  use Magma.Matter, fields: [:type]

  alias Magma.{Matter, Concept}

  @type t :: %__MODULE__{}

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
  def prompt_concept_description_title(%__MODULE__{name: name, type: text_type}) do
    "Description of the content to be covered by the '#{name}' #{text_type.label}"
  end

  @impl true
  def custom_sections(%Concept{} = concept) do
    """

    # #{@sections_section_title}

    #{View.comment("Don't remove or edit this section! The results of the generated table of contents will be copied to this place.")}


    # Artefact previews

    """ <>
      Enum.map_join(
        Matter.Text.Section.artefacts(),
        "\n",
        &"- #{View.link_to_preview({concept, &1})}"
      )
  end

  @impl true
  def new(attrs) when is_list(attrs) do
    {:ok, struct(__MODULE__, attrs)}
  end

  def new(type, name) do
    new(name: name, type: type)
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  def new!(type, name) do
    case new(type, name) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(document_name, _document_title, metadata) do
    {magma_matter_text_type, remaining} = Map.pop(metadata, :magma_matter_text_type)

    cond do
      !magma_matter_text_type ->
        {:error, "magma_matter_text_type missing in #{document_name}"}

      text_type = type(magma_matter_text_type) ->
        with {:ok, matter} <- new(text_type, document_name) do
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

      iex> Magma.Matter.Text.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Matter.Text type: Magma.Vault

      iex> Magma.Matter.Text.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Matter.Text type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
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

      iex> Magma.Matter.Text.type("Vault")
      nil

      iex> Magma.Matter.Text.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Matter.Texts, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :system_prompt_task, 1)
  end
end

```

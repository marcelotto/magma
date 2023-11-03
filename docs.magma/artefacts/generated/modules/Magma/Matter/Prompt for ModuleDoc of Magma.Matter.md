---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-19 15:57:48
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

Final version: [[ModuleDoc of Magma.Matter]]

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

# Prompt for ModuleDoc of Magma.Matter

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

##### `Magma.Matter.Project` ![[Magma.Matter.Project#Description|]]

##### `Magma.Matter.Module` ![[Magma.Matter.Module#Description|]]

##### `Magma.Matter.Text` ![[Magma.Matter.Text#Description|]]

##### Magma artefact model ![[Magma artefact model#Description|]]

![[Magma artefact model#Sequence diagram|]]


## Request

![[Magma.Matter#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter` ![[Magma.Matter#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  alias Magma.Concept

  @fields [:name]
  @doc """
  Returns a list of the shared fields of the structs of every type of `Magma.Matter`.

      iex> Magma.Matter.fields()
      #{inspect(@fields)}

  """
  def fields, do: @fields

  @doc """
  A callback that returns the list of `Magma.Artefact` types that are available for this matter type.
  """
  @callback artefacts :: list(Magma.Artefact.t())

  @doc """
  A callback that returns the path segment to be used for different kinds of documents for this type of matter.

  This path segment will be incorporated in the path generator functions
  of the `Magma.Document` types.
  """
  @callback relative_base_path(t()) :: Path.t()

  @doc """
  A callback that returns the path for `Magma.Concept` documents about this type of matter.

  This path is relative to the `Magma.Vault.concept_path/0`
  """
  @callback relative_concept_path(t()) :: Path.t()

  @doc """
  A callback that returns the name of the `Magma.Concept` document.

  Note that this name must unique across all document names in the vault.
  """
  @callback concept_name(t()) :: binary

  @doc """
  A callback that returns the title header text of the `Magma.Concept` document.
  """
  @callback concept_title(t()) :: binary

  @doc """
  A callback that returns a text for the body of the "Description" section in the `Magma.Concept` document.

  As the description is something written by the user, this should return
  a comment with a hint of what is expected to be written.
  """
  @callback default_description(t(), keyword) :: binary

  @doc """
  A callback that can be used to define additional sections for the `Magma.Concept` document.
  """
  @callback custom_concept_sections(Concept.t()) :: binary | nil

  @doc """
  A callback that allows to specify texts which should be included generally in the "Context knowledge" section of the `Magma.Concept` document about this type of matter.
  """
  @callback context_knowledge(Concept.t()) :: binary | nil

  @doc """
  A callback that returns the section title for the concept description of a type of matter in the `Magma.Artefact.Prompt`.
  """
  @callback prompt_concept_description_title(t()) :: binary

  @doc """
  A callback that can be used to define a general description of some matter which should be included in the `Magma.Artefact.Prompt`.

  This is used for example to include the code of module, in the case of `Magma.Matter.Module`.
  """
  @callback prompt_matter_description(t()) :: binary | nil

  @doc """
  A callback that returns a list of Obsidian aliases for the `Magma.Concept` document of this type of matter.
  """
  @callback default_concept_aliases(t()) :: list

  @doc """
  A callback that renders the matter-specific fields of this type of matter to YAML frontmatter.

  Counterpart of `extract_from_metadata/3`.
  """
  @callback render_front_matter(t()) :: binary

  @doc """
  A callback that extracts an instance of this matter type from the matter-specific fields of the metadata during deserialization of a `Magma.Concept` document.

  All YAML frontmatter properties are loaded first into the `:custom_metadata`
  map of a `Magma.Document`. This callback implementation should `Map.pop/2` the
  matter-specific entries from the given `document_metadata` and return the created
  instance of this matter type and the consumed metadata in an ok tuple.

  Counterpart of `render_front_matter/1`.
  """
  @callback extract_from_metadata(
              document_name :: binary,
              document_title :: binary,
              document_metadata :: map
            ) :: {:ok, t(), keyword} | {:error, any}

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      alias Magma.View

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def custom_concept_sections(%Concept{}), do: nil

      @impl true
      def context_knowledge(%Concept{}), do: nil

      @impl true
      def prompt_matter_description(%__MODULE__{}), do: nil

      @impl true
      def render_front_matter(%__MODULE__{}) do
        "magma_matter_type: #{Magma.Matter.type_name(__MODULE__)}"
      end

      @impl true
      def extract_from_metadata(document_name, _document_title, metadata) do
        with {:ok, matter} <- new(name: document_name) do
          {:ok, matter, metadata}
        end
      end

      defoverridable default_concept_aliases: 1,
                     custom_concept_sections: 1,
                     context_knowledge: 1,
                     prompt_matter_description: 1,
                     render_front_matter: 1,
                     extract_from_metadata: 3
    end
  end

  @doc """
  Extracts an instance of a matter from the matter-specific fields of the metadata of a `Magma.Concept` document.

  This function first extracts the matter type from the `magma_matter_type` field
  in the YAML frontmatter and then delegates to the `c:extract_from_metadata/3`
  implementation to process the matter-type specific fields.
  """
  def extract_from_metadata(document_name, document_title, metadata) do
    with {:ok, matter_type, remaining_metadata} <- extract_type(metadata) do
      matter_type.extract_from_metadata(document_name, document_title, remaining_metadata)
    end
  end

  defp extract_type(metadata) do
    {matter_type, remaining} = Map.pop(metadata, :magma_matter_type)

    cond do
      !matter_type -> {:error, "magma_matter_type missing"}
      matter_module = type(matter_type) -> {:ok, matter_module, remaining}
      true -> {:error, "invalid magma_matter type: #{matter_type}"}
    end
  end

  @doc """
  Returns the matter type name for the given matter type module.

  ## Example

      iex> Magma.Matter.type_name(Magma.Matter.Module)
      "Module"

      iex> Magma.Matter.type_name(Magma.Matter.Text)
      "Text"

      iex> Magma.Matter.type_name(Magma.Matter.Text.Section)
      "Text.Section"

      iex> Magma.Matter.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Matter type: Magma.Vault

      iex> Magma.Matter.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Matter type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Matter" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Matter type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Matter type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the matter type module for the given string.

  ## Example

      iex> Magma.Matter.type("Module")
      Magma.Matter.Module

      iex> Magma.Matter.type("Project")
      Magma.Matter.Project

      iex> Magma.Matter.type("Vault")
      nil

      iex> Magma.Matter.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if type?(module) do
      module
    end
  end

  @doc """
  Checks if the given `module` is a `Magma.Matter` type module.
  """
  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_concept_path, 1)
  end
end

```

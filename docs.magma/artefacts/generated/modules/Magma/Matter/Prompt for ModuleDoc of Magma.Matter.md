---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:19
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

##### `Magma.Matter.Project` ![[Magma.Matter.Project#Description|]]

##### `Magma.Matter.Module` ![[Magma.Matter.Module#Description|]]

##### `Magma.Matter.Text` ![[Magma.Matter.Text#Description|]]


## Request

### ![[Magma.Matter#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter` ![[Magma.Matter#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  alias Magma.Concept

  @fields [:name]
  def fields, do: @fields

  @callback artefacts :: list(Magma.Artefact.t())

  @callback relative_base_path(t()) :: Path.t()

  @callback relative_concept_path(t()) :: Path.t()

  @callback concept_name(t()) :: binary

  @callback concept_title(t()) :: binary

  @callback default_description(t(), keyword) :: binary

  @callback custom_sections(Concept.t()) :: binary | nil

  @callback context_knowledge(Concept.t()) :: binary | nil

  @callback prompt_concept_description_title(t()) :: binary

  @callback prompt_matter_description(t()) :: binary | nil

  @callback default_concept_aliases(t()) :: list

  @callback new(keyword) :: {:ok, t(), keyword} | {:error, any}

  @callback extract_from_metadata(
              document_name :: binary,
              document_title :: binary,
              document_metadata :: keyword
            ) :: {:ok, t(), keyword} | {:error, any}

  @callback render_front_matter(t()) :: binary

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      alias Magma.View

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def custom_sections(%Concept{}), do: nil

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
                     custom_sections: 1,
                     context_knowledge: 1,
                     prompt_matter_description: 1,
                     render_front_matter: 1,
                     extract_from_metadata: 3
    end
  end

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
  Returns the matter type name for the given matter module.

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
  Returns the matter module for the given string.

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

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_concept_path, 1)
  end
end

```

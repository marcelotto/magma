---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefact]]"
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

Final version: [[ModuleDoc of Magma.Artefact]]

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

# Prompt for ModuleDoc of Magma.Artefact

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

##### `Magma.Artefact.Prompt` ![[Magma.Artefact.Prompt#Description|]]

##### `Magma.Artefact.Version` ![[Magma.Artefact.Version#Description|]]


## Request

### ![[Magma.Artefact#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefact` ![[Magma.Artefact#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefact do
  alias Magma.Concept
  alias __MODULE__

  @type t :: module

  @callback name(Concept.t()) :: binary

  @callback prompt_name(Concept.t()) :: binary

  @callback system_prompt_task(Concept.t()) :: binary

  @callback request_prompt_task(Concept.t()) :: binary

  @callback concept_section_title :: binary

  @callback concept_prompt_task_section_title :: binary

  @callback version_prologue(Artefact.Version.t()) :: binary | nil

  @callback trim_prompt_result_header? :: boolean

  @callback relative_base_path(Concept.t()) :: Path.t()

  @callback relative_prompt_path(Concept.t()) :: Path.t()

  @callback relative_version_path(Concept.t()) :: Path.t()

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      def matter_type, do: unquote(matter_type)

      @impl true
      def concept_section_title, do: Artefact.type_name(__MODULE__)

      @impl true
      def concept_prompt_task_section_title, do: "#{concept_section_title()} prompt task"

      @impl true
      def prompt_name(%Concept{} = concept), do: "Prompt for #{name(concept)}"

      @impl true
      def relative_prompt_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{prompt_name(concept)}.md")
      end

      @impl true
      def relative_version_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{name(concept)}.md")
      end

      @impl true
      def version_prologue(%Artefact.Version{artefact: __MODULE__}), do: nil

      @impl true
      def trim_prompt_result_header?, do: true

      def prompt(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new(concept, __MODULE__, attrs)
      end

      def prompt!(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new!(concept, __MODULE__, attrs)
      end

      def create_prompt(
            %Concept{subject: %unquote(matter_type){}} = concept,
            attrs \\ [],
            opts \\ []
          ) do
        Artefact.Prompt.create(concept, __MODULE__, attrs, opts)
      end

      def load_version(%Concept{} = concept) do
        concept
        |> name()
        |> Artefact.Version.load()
      end

      def load_version!(concept) do
        case load_version(concept) do
          {:ok, version} -> version
          {:error, error} -> raise error
        end
      end

      defoverridable prompt_name: 1,
                     version_prologue: 1,
                     trim_prompt_result_header?: 0,
                     relative_prompt_path: 1,
                     relative_version_path: 1
    end
  end

  @doc """
  Returns the artefact type name for the given artefact module.

  ## Example

      iex> Magma.Artefact.type_name(Magma.Artefacts.ModuleDoc)
      "ModuleDoc"

      iex> Magma.Artefact.type_name(Magma.Artefacts.Article)
      "Article"

      iex> Magma.Artefact.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Artefacts type: Magma.Vault

      iex> Magma.Artefact.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Artefacts type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Artefacts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Artefacts type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Artefacts type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the artefact module for the given string.

  ## Example

      iex> Magma.Artefact.type("ModuleDoc")
      Magma.Artefacts.ModuleDoc

      iex> Magma.Artefact.type("TableOfContents")
      Magma.Artefacts.TableOfContents

      iex> Magma.Artefact.type("Vault")
      nil

      iex> Magma.Artefact.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Artefacts, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_prompt_path, 1)
  end
end

```

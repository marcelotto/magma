---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Project]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
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

Final version: [[ModuleDoc of Magma.Matter.Project]]

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

# Prompt for ModuleDoc of Magma.Matter.Project

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


## Request

### ![[Magma.Matter.Project#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Project` ![[Magma.Matter.Project#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Project do
  use Magma.Matter

  @type t :: %__MODULE__{}

  alias Magma.{Matter, Concept}

  @impl true
  def artefacts, do: []

  @impl true
  def new(name: name), do: new(name)

  def new(name) do
    {:ok, %__MODULE__{name: name}}
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(_document_name, _document_title, metadata) do
    case Map.pop(metadata, :magma_matter_name) do
      {nil, _} ->
        {:error, "magma_matter_name with project name missing in Project document"}

      {matter_name, remaining} ->
        with {:ok, matter} <- new(matter_name) do
          {:ok, matter, remaining}
        end
    end
  end

  def render_front_matter(%__MODULE__{} = matter) do
    """
    #{super(matter)}
    magma_matter_name: #{matter.name}
    """
    |> String.trim_trailing()
  end

  @impl true
  def default_concept_aliases(%__MODULE__{name: name}), do: ["#{name} project", "#{name}-project"]

  @impl true
  def relative_base_path(_), do: ""

  @impl true
  def relative_concept_path(%__MODULE__{} = project), do: "#{concept_name(project)}.md"

  @impl true
  def concept_name(%__MODULE__{}), do: "Project"

  @impl true
  def concept_title(%__MODULE__{name: name}), do: "#{name} project"

  @impl true
  def default_description(%__MODULE__{name: name}, _) do
    """
    What is the #{name} project about?
    """
    |> String.trim_trailing()
    |> View.comment()
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the '#{name}' project"
  end

  def app_name, do: Mix.Project.config()[:app]

  def version, do: Mix.Project.config()[:version]

  def concept, do: Concept.load!("Project")

  def modules do
    with {:ok, modules} <- :application.get_key(app_name(), :modules) do
      modules
      |> Enum.reject(&Matter.Module.ignore?/1)
      |> Enum.map(&Matter.Module.new!(&1))
    end
  end
end

```

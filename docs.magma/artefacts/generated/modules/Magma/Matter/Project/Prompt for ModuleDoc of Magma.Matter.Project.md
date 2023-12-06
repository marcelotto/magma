---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Project]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.5}
created_at: 2023-12-06 16:35:51
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

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Matter.Project#Context knowledge|]]


## Request

![[Magma.Matter.Project#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Project` ![[Magma.Matter.Project#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Project do
  @moduledoc """
  `Magma.Matter` type behaviour implementation for the project Magma is used for.

  It is unique in the sense that there is only one instance of it, corresponding
  to the one project for which artefacts are being created. It plays a central
  role as its description (in the corresponding `Magma.Concept` about this matter)
  is included in every prompt.

  The single `Magma.Concept` for the project can be fetched with the `concept/0`
  function.

  """

  use Magma.Matter

  @type t :: %__MODULE__{}

  alias Magma.{Matter, Concept}

  @concept_name "Project"

  @generated_artefacts_base_path "project"

  @artefacts [Magma.Artefacts.Readme]

  @doc """
  Returns the list of `Magma.Artefact` types available for a project.

      iex> Magma.Matter.Project.artefacts()
      #{inspect(@artefacts)}

  """
  @impl true
  def artefacts, do: @artefacts

  @doc """
  Creates a new `Magma.Matter.Project` instance from the given name in an ok tuple.
  """
  @spec new(binary | [name: binary]) :: {:ok, t()} | {:error, any}
  def new(name: name), do: new(name)

  def new(name) do
    {:ok, %__MODULE__{name: name}}
  end

  @doc """
  Creates a new `Magma.Matter.Project` instance from the given name and fails in error cases.
  """
  @spec new(binary | [name: binary]) :: t()
  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @doc """
  Extracts the project name from the metadata of a `Magma.Concept` document about the project and creates a new instance with it.

  The project name must be specified in the `magma_matter_name` YAML frontmatter property.
  If the project name is not found, it returns an error.
  """
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

  @doc """
  Renders the YAML frontmatter properties specific for the `Magma.Concept` document about the project.

  In particular this includes `magma_matter_name` with the project name.
  """
  def render_front_matter(%__MODULE__{} = matter) do
    """
    #{super(matter)}
    magma_matter_name: #{matter.name}
    """
    |> String.trim_trailing()
  end

  @doc """
  Returns a list of Obsidian aliases for the `Magma.Concept` document about the project.

  ### Example

      iex> "Example"
      ...> |> Magma.Matter.Project.new!()
      ...> |> Magma.Matter.Project.default_concept_aliases()
      ["Example project", "Example-project"]

  """
  @impl true
  def default_concept_aliases(%__MODULE__{name: name}), do: ["#{name} project", "#{name}-project"]

  @doc """
  Returns the base path segment to be used for the document about the project.

  Since there is just one such matter, and it has a central, this base path is
  empty, meaning it these documents are placed all at the root of the folders
  for the different document types.
  """
  @impl true
  def relative_base_path(_), do: ""

  @doc """
  Returns the path for `Magma.Concept` document about the project.

  See also `concept_name/1`.

  ### Example

      iex> "Example"
      ...> |> Magma.Matter.Project.new!()
      ...> |> Magma.Matter.Project.relative_concept_path()
      "#{@concept_name}.md"

  """
  @impl true
  def relative_concept_path(%__MODULE__{} = project), do: "#{concept_name(project)}.md"

  @doc false
  def relative_generated_artefacts_path, do: @generated_artefacts_base_path

  @doc """
  Returns the name of the `Magma.Concept` document about the project.

  In order to not get in name conflict with any other document (e.g. the
  document about the top-level module which is usually the project name),
  and there's only one such matter the project concept is generally called
  "Project".

  ### Example

      iex> "Example"
      ...> |> Magma.Matter.Project.new!()
      ...> |> Magma.Matter.Project.concept_name()
      #{inspect(@concept_name)}

  """
  @impl true
  def concept_name(%__MODULE__{}), do: @concept_name

  @doc """
  Returns the title header text of the `Magma.Concept` document about the project.

  ### Example

      iex> "Example"
      ...> |> Magma.Matter.Project.new!()
      ...> |> Magma.Matter.Project.concept_title()
      "Example project"

  """
  @impl true
  def concept_title(%__MODULE__{name: name}), do: "#{name} project"

  @doc """
  Returns a default description for the `Magma.Concept` about the project.
  """
  @impl true
  def default_description(%__MODULE__{name: name}, _) do
    """
    What is the #{name} project about?
    """
    |> View.comment()
  end

  @doc """
  Returns the title for the description section of the project in artefact prompts.

  ### Example

      iex> "Example"
      ...> |> Magma.Matter.Project.new!()
      ...> |> Magma.Matter.Project.prompt_concept_description_title()
      "Description of the 'Example' project"

  """
  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the '#{name}' project"
  end

  @doc """
  Returns the project's app name as specified in the `mix.exs` file.
  """
  @spec app_name :: binary
  def app_name, do: Mix.Project.config()[:app]

  @doc """
  Returns the project's version as specified in the `mix.exs` file.
  """
  @spec version :: binary
  def version, do: Mix.Project.config()[:version]

  @doc """
  Returns the `Magma.Concept` about the project.
  """
  @spec concept :: {:ok, Magma.Concept.t()} | {:error, any}
  def concept, do: Concept.load(@concept_name)

  @doc """
  Returns all modules of the project as `Magma.Matter.Module`s.

  which are not ignored in terms of `Magma.Matter.Module.ignore?/1`
  """
  @spec modules :: [Magma.Matter.Module.t()]
  def modules do
    with {:ok, modules} <- :application.get_key(app_name(), :modules) do
      modules
      |> Enum.reject(&Matter.Module.ignore?/1)
      |> Enum.map(&Matter.Module.new!(&1))
    end
  end
end

```

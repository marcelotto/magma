---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.System]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: 2023-12-06 16:35:50
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

Final version: [[ModuleDoc of Magma.Config.System]]

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

# Prompt for ModuleDoc of Magma.Config.System

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Config.System#Context knowledge|]]


## Request

![[Magma.Config.System#ModuleDoc prompt task|]]

### Description of the module `Magma.Config.System` ![[Magma.Config.System#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Config.System do
  use Magma.Config.Document

  @type t :: %__MODULE__{}

  alias Magma.{Generation, View}

  @name "Magma.system.config"
  def name, do: @name

  def path, do: Magma.Config.path("#{@name}.md")

  @impl true
  def title(%__MODULE__{}), do: title()
  def title, do: "Magma system config"

  @persona_section_title "Persona"
  def persona_section_title, do: @persona_section_title

  @impl true
  def build_path(%__MODULE__{}), do: {:ok, path()}

  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
    |> Document.init_path()
  end

  def new!(attrs \\ []) do
    case new(attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def template(project_name) do
    """
    ---
    magma_type: Config.System
    tags: [magma-config]
    default_tags: #{View.yaml_list(default_tags())}
    """ <>
      generation_default_properties() <>
      """
      link_resolution_style: #{default_link_resolution_style()}
      ---
      # #{title()}

      ## #{@persona_section_title}

      #{default_persona(project_name)}


      ## Context knowledge

      """
  end

  def default_generation do
    type =
      Application.get_env(
        :magma,
        :default_generation,
        if(Code.ensure_loaded?(Magma.Generation.OpenAI),
          do: Magma.Generation.OpenAI,
          else: Magma.Generation.Manual
        )
      )

    type.new!()
  end

  def default_tags do
    Application.get_env(:magma, :default_tags) |> List.wrap()
  end

  def default_link_resolution_style do
    Application.get_env(:magma, :link_resolution_style, :plain)
  end

  def default_persona(project_name) do
    Application.get_env(
      :magma,
      :persona,
      """
      You are MagmaGPT, an assistant who helps the developers of the "#{project_name}" project during documentation and development. Your responses are in plain and clear English.
      """
    )
    |> String.trim_trailing()
  end

  defp generation_default_properties do
    %generation_type{} = generation = default_generation()
    generation_params = Map.from_struct(generation)

    """
    default_generation_type: #{inspect(Generation.short_name(generation_type))}
    """ <>
      if Enum.empty?(generation_params) do
        ""
      else
        """
        default_generation_params: #{View.yaml_nested_map(generation_params)}
        """
      end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = document) do
    with {:ok, document} <- super(document),
         {:ok, config} <- setup_default_generation(document.custom_metadata) do
      {:ok,
       %__MODULE__{
         document
         | custom_metadata:
             config
             |> setup_default_tags()
             |> setup_link_resolution_style()
       }}
    end
  end

  defp setup_default_generation(metadata) do
    {default_generation_type_name, metadata} = Map.pop(metadata, :default_generation_type)
    {default_generation_params, metadata} = Map.pop(metadata, :default_generation_params, [])

    with {:ok, default_generation} <-
           (cond do
              Mix.env() == :test || !default_generation_type_name ->
                {:ok, default_generation()}

              default_generation_type = Generation.type(default_generation_type_name) ->
                {:ok, default_generation_type.new!(Keyword.new(default_generation_params))}

              true ->
                {:error,
                 "invalid default_generation_type in Magma system config: #{default_generation_type_name}"}
            end) do
      {:ok, Map.put(metadata, :default_generation, default_generation)}
    end
  end

  defp setup_default_tags(metadata) do
    Map.update(metadata, :default_tags, default_tags(), &List.wrap/1)
  end

  defp setup_link_resolution_style(metadata) do
    Map.update(
      metadata,
      :link_resolution_style,
      default_link_resolution_style(),
      &String.to_atom/1
    )
  end

  def load, do: load(@name)

  @persona_transclusion View.transclude(@name, @persona_section_title)
  def persona_transclusion, do: @persona_transclusion

  @context_knowledge_transclusion View.transclude(
                                    @name,
                                    Magma.Config.Document.context_knowledge_section_title()
                                  )
  def context_knowledge_transclusion, do: @context_knowledge_transclusion
end

```

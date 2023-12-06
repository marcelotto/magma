---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.TextType]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: 2023-12-06 16:35:49
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

Final version: [[ModuleDoc of Magma.Config.TextType]]

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

# Prompt for ModuleDoc of Magma.Config.TextType

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Config.TextType#Context knowledge|]]


## Request

![[Magma.Config.TextType#ModuleDoc prompt task|]]

### Description of the module `Magma.Config.TextType` ![[Magma.Config.TextType#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Config.TextType do
  use Magma.Config.Document, fields: [:text_type, :label]

  alias Magma.View

  @impl true
  def title(%__MODULE__{text_type: text_type}),
    do: "#{Magma.Matter.Text.type_name(text_type, false)} text type config"

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title

  @impl true
  def build_path(%__MODULE__{text_type: text_type}),
    do: {:ok, Magma.Config.text_types_path("#{name_by_type(text_type)}.md")}

  def name_by_type(text_type),
    do: "#{Magma.Matter.Text.type_name(text_type, false)}.text_type.config"

  def new(text_type_name, attrs \\ []) when is_binary(text_type_name) do
    {label, attrs} = Keyword.pop(attrs, :label)

    attrs =
      if label,
        do:
          Keyword.update(
            attrs,
            :custom_metadata,
            %{text_type_label: label},
            &Map.put(&1, :text_type_label, label)
          ),
        else: attrs

    struct(
      __MODULE__,
      Keyword.put(attrs, :text_type, Magma.Matter.Text.type(text_type_name, false))
    )
    |> Document.init_path()
  end

  def new!(text_type_name, attrs \\ []) do
    case new(text_type_name, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(text_type_name, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document
    |> Magma.Config.Document.init()
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Config.TextType.create/3 is available only with an initialized document"
      )

  def create(text_type_name, attrs, opts) do
    with {:ok, document} <- new(text_type_name, attrs) do
      create(document, opts)
    end
  end

  defp render(document) do
    %__MODULE__{
      document
      | content: """
        # #{title(document)}

        ## #{@system_prompt_section_title}


        ## Context knowledge

        """
    }
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = document) do
    with {:ok, document} <- super(document) do
      {:ok,
       %__MODULE__{
         document
         | text_type: document |> type_name() |> Magma.Matter.Text.type(false)
       }}
    end
  end

  defp type_name(%__MODULE__{name: name}), do: Path.basename(name, ".text_type.config")

  def context_knowledge_transclusion(text_type) do
    text_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end

```

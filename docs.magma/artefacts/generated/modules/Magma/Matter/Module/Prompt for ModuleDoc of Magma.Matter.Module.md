---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Module]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-19 16:34:49
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

Final version: [[ModuleDoc of Magma.Matter.Module]]

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

# Prompt for ModuleDoc of Magma.Matter.Module

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

##### `Magma.Matter` ![[Magma.Matter#Description|]]


## Request

![[Magma.Matter.Module#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Module` ![[Magma.Matter.Module#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Module do
  # We don't have any additional fields, since we can get everything
  # via the Elixir and Erlang reflection API from the module name
  use Magma.Matter

  alias Magma.Concept

  import Magma.Utils.Guards

  @type t :: %__MODULE__{}

  @relative_base_path "modules"

  @impl true
  def artefacts, do: [Magma.Artefacts.ModuleDoc]

  def new(name: name), do: new(name)

  def new(name) when is_binary(name) do
    Elixir |> Module.concat(name) |> new()
  end

  def new(module) when maybe_module(module) do
    {:ok, %__MODULE__{name: module}}
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def relative_base_path(_), do: @relative_base_path

  @impl true
  def relative_concept_path(%__MODULE__{name: module} = matter) do
    [@relative_base_path | context_segments(module)]
    |> Path.join()
    |> Path.join("#{concept_name(matter)}.md")
  end

  defp context_segments(module) do
    module |> Module.split() |> List.delete_at(-1)
  end

  def context_modules(module) do
    {result, _} =
      module
      |> context_segments()
      |> Enum.map_reduce(nil, fn module_segment, context ->
        module = Module.concat(context, module_segment)
        {module, module}
      end)

    result
  end

  def submodules(module) do
    {:ok, path} = module |> Module.concat(X) |> new!() |> Concept.build_path()
    module_path = Path.dirname(path)

    if File.exists?(module_path) do
      module_path
      |> File.ls!()
      |> Enum.filter(&(Path.extname(&1) == ".md"))
      |> Enum.map(&Module.concat(Elixir, &1 |> Path.basename(".md") |> String.to_atom()))
    end
  end

  @impl true
  def concept_name(%__MODULE__{name: module}), do: inspect(module)

  @impl true
  def concept_title(%__MODULE__{name: module}), do: "`#{inspect(module)}`"

  @impl true
  def default_description(%__MODULE__{} = matter, _) do
    """
    What is a #{concept_title(matter)}?

    Your knowledge about the module, i.e. facts, problems and properties etc.
    """
    |> View.comment()
  end

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{name: module}}) do
    """
    #### Peripherally relevant modules

    #{context_modules_knowledge(module)}
    """
    |> String.trim_trailing()
  end

  defp context_modules_knowledge(module) do
    context_modules =
      case context_modules(module) do
        # ignore modules for Mix tasks
        [Mix | _] -> []
        context_modules -> context_modules
      end

    submodules = module |> submodules() |> List.wrap()

    Enum.map_join(context_modules ++ submodules, "\n", &context_module_knowledge/1)
  end

  defp context_module_knowledge(module) do
    matter = new!(module)

    """
    ##### `#{inspect(module)}` #{matter |> concept_name() |> View.transclude("Description")}
    """
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the module `#{inspect(name)}`"
  end

  @impl true
  def prompt_matter_description(%__MODULE__{} = matter) do
    """
    ### Module code

    This is the code of the module to be documented. Ignore commented out code.

    ```elixir
    #{code(matter)}
    ```
    """
  end

  def source_path(%__MODULE__{name: module}), do: source_path(module)

  def source_path(module) when maybe_module(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__info__, 1) do
      if source = module.__info__(:compile)[:source], do: to_string(source)
    end
  end

  def code(%__MODULE__{name: module}), do: code(module)

  def code(module) when maybe_module(module) do
    if (source_path = source_path(module)) && File.exists?(source_path) do
      code(source_path)
    end
  end

  def code(path) when is_binary(path) do
    File.read!(path)
  end

  @ignore_pragma "# Magma pragma: ignore"
  @include_pragma "# Magma pragma: include"

  def ignore?(module) do
    if module_code = code(module) do
      module_code = String.trim_leading(module_code)

      String.starts_with?(module_code, @ignore_pragma) or
        (hidden?(module) and not String.starts_with?(module_code, @include_pragma))
    else
      true
    end
  end

  defp hidden?(module) do
    match?(
      {_docs_v1, _annotation, _beam_language, _format, :hidden, _metadata, _docs},
      Code.fetch_docs(module)
    )
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Generation]]"
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

Final version: [[ModuleDoc of Magma.Generation]]

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

# Prompt for ModuleDoc of Magma.Generation

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

##### `Magma.Generation.OpenAI` ![[Magma.Generation.OpenAI#Description|]]

##### `Magma.Generation.Manual` ![[Magma.Generation.Manual#Description|]]


## Request

### ![[Magma.Generation#ModuleDoc prompt task|]]

### Description of the module `Magma.Generation` ![[Magma.Generation#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Generation do
  alias Magma.Artefact

  import Magma.Utils.Guards

  @type options :: keyword

  @type t :: struct
  @type prompt :: binary
  @type system_prompt :: prompt
  @type result :: binary

  @callback execute(t(), Artefact.Prompt.t(), options) :: {:ok, result} | {:error, any}

  def default do
    Application.get_env(:magma, :default_generation, Magma.Generation.OpenAI)
  end

  def execute(prompt) when is_prompt(prompt) do
    execute(prompt.generation, prompt)
  end

  def execute(%generation_type{} = generation, prompt, opts \\ []) when is_prompt(prompt) do
    generation_type.execute(generation, prompt, opts)
  end

  @doc """
  Returns the generation module for the given string.

  ## Example

      iex> Magma.Generation.type("OpenAI")
      Magma.Generation.OpenAI

      iex> Magma.Generation.type("Manual")
      Magma.Generation.Manual

      iex> Magma.Generation.type("Mock")
      Magma.Generation.Mock

      iex> Magma.Generation.type("Vault")
      nil

      iex> Magma.Generation.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if Code.ensure_loaded?(module) and function_exported?(module, :execute, 3) do
      module
    end
  end

  @doc """
  Returns the short version of the `Magma.Generation` implementation name.

  This is used as the `magma_generation` value in the YAML frontmatter.

  ## Example

      iex> Magma.Generation.short_name(Magma.Generation.OpenAI)
      OpenAI

      iex> Magma.Generation.short_name(Magma.Generation.Bumblebee.TextGeneration.Llama)
      Bumblebee.TextGeneration.Llama

  """
  def short_name(%module{}), do: short_name(module)

  def short_name(module) when maybe_module(module) do
    case Module.split(module) do
      ["Magma", "Generation" | rest] -> Module.concat(rest)
      _ -> raise("invalid Magma.Generation: #{inspect(module)}")
    end
  end

  def extract_from_metadata(metadata) do
    {generation_type, custom_metadata} = Map.pop(metadata, :magma_generation_type)
    {generation_params, custom_metadata} = Map.pop(custom_metadata, :magma_generation_params)

    cond do
      !generation_type || !generation_params ->
        {:ok, nil, metadata}

      !generation_type ->
        {:error, "magma_generation_params without magma_generation_type"}

      !generation_params ->
        {:error, "magma_generation_type without magma_generation_params"}

      generation_module = type(generation_type) ->
        with {:ok, generation} <- generation_module.new(generation_params) do
          {:ok, generation, custom_metadata}
        end

      true ->
        {:error, "invalid magma_generation_type type: #{generation_type}"}
    end
  end
end

```

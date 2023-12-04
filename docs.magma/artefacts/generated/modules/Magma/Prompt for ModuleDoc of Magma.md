---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:50
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

Final version: [[ModuleDoc of Magma]]

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

# Prompt for ModuleDoc of Magma

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Magma#Context knowledge|]]


## Request

![[Magma#ModuleDoc prompt task|]]

### Description of the module `Magma` ![[Magma#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma do
  @moduledoc """
  Magma is an environment for writing and executing complex prompts.

  It is primarily designed to support developers in documenting their projects.
  It provides a system of documents for predefined workflows, to generate
  various documentation artefacts.

  Read the [User Guide](Magma User Guide - Introduction to Magma (article section).md) to learn more.
  """

  @version_file "VERSION"
  @version @version_file |> File.read!() |> String.trim() |> Version.parse!()
  @external_resource @version_file

  def version, do: @version

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [defmoduledoc: 0]

      defmoduledoc()
    end
  end

  @doc """
  Adds the contents of the final version of the `Magma.Artefacts.ModuleDoc` as the `@moduledoc`.

  Usually this done via `use Magma`.

  > #### warning {: .warning}
  >
  > If you decide to include your moduledocs with this macro, be aware that if
  > you're writing a library and your users should be able to use these docs on
  > their machines, e.g. with the `h` helper in IEx you'll have to include the
  > Magma documents with the final moduledocs in your package like this:
  >
  > ```elixir
  > defp package do
  >   [
  >     # ...
  >     files:  ~w[lib priv mix.exs docs.magma/artefacts/final/modules/**/*.md]
  >   ]
  > end
  > ```

  """
  defmacro defmoduledoc do
    quote do
      magma_moduledoc_path = Magma.Artefacts.ModuleDoc.version_path(__MODULE__)
      @external_resource magma_moduledoc_path

      if moduledoc = Magma.Artefacts.ModuleDoc.get(__MODULE__) do
        @moduledoc moduledoc
      else
        Magma.__moduledoc_artefact_not_found__(__MODULE__, magma_moduledoc_path)
      end
    end
  end

  @doc false
  def __moduledoc_artefact_not_found__(module, path) do
    case Application.get_env(:magma, :on_moduledoc_artefact_not_found) do
      :warn ->
        IO.warn("No Magma artefact for moduledoc of #{inspect(module)} found at #{path}")

      _ ->
        nil
    end
  end
end

```

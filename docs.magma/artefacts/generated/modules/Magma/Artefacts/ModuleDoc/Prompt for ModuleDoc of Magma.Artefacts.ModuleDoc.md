---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefacts.ModuleDoc]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-06 16:03:18
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

Final version: [[ModuleDoc of Magma.Artefacts.ModuleDoc]]

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

# Prompt for ModuleDoc of Magma.Artefacts.ModuleDoc

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

##### `Magma.Artefacts` ![[Magma.Artefacts#Description|]]


## Request

### ![[Magma.Artefacts.ModuleDoc#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefacts.ModuleDoc` ![[Magma.Artefacts.ModuleDoc#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter, DocumentStruct}
  alias Magma.View

  import Magma.Utils.Guards

  @prompt_result_section_title "Moduledoc"
  def prompt_result_section_title, do: @prompt_result_section_title

  @impl true
  def name(concept), do: "ModuleDoc of #{concept.name}"

  @impl true
  def system_prompt_task(_concept) do
    """
    Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

    ```markdown
    ## #{@prompt_result_section_title}

    The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

    Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


    ## Function docs

    In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

    ### `function/1`

    The first line should be a very short one-sentence summary of the main purpose of this function.

    Then follows the main body of the function documentation.
    ```

    #{View.comment("You can edit this prompt, as long you ensure the moduledoc is generated in a section named '#{@prompt_result_section_title}', as the contents of this section is used for the @moduledoc.")}

    """
    |> String.trim_trailing()
  end

  @impl true
  def request_prompt_task(concept) do
    """
    Generate documentation for module `#{concept.name}` according to its description and code in the knowledge base below.
    """
    |> String.trim_trailing()
  end

  @impl true
  def version_prologue(%Artefact.Version{artefact: __MODULE__}) do
    """
    Ensure that the module documentation is under a "#{@prompt_result_section_title}" section, as the contents of this section is used for the `@moduledoc`.

    Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.
    """
    |> String.trim_trailing()
    |> View.callout("caution")
  end

  @impl true
  def trim_prompt_result_header?, do: false

  @impl true
  def relative_base_path(%Concept{subject: %Matter.Module{name: module} = matter}) do
    Path.join([Matter.Module.relative_base_path(matter) | Module.split(module)])
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new!()
    |> Concept.new!()
    |> Artefact.Version.build_path(__MODULE__)
    |> case do
      {:ok, path} -> path
      _ -> nil
    end
  end

  def get(mod) do
    path = version_path(mod)

    if File.exists?(path) do
      with {:ok, document_struct} <-
             path
             |> File.read!()
             |> Magma.DocumentStruct.parse() do
        if section =
             DocumentStruct.section_by_title(document_struct, @prompt_result_section_title) do
          section
          |> DocumentStruct.Section.to_string(header: false)
          |> String.trim()
        else
          raise "invalid ModuleDoc artefact version document at #{path}: no '#{@prompt_result_section_title}' section found"
        end
      else
        {:error, error} ->
          raise "invalid ModuleDoc artefact version document at #{path}: #{inspect(error)}"
      end
    end
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefacts.TableOfContents]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
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

Final version: [[ModuleDoc of Magma.Artefacts.TableOfContents]]

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

# Prompt for ModuleDoc of Magma.Artefacts.TableOfContents

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

### ![[Magma.Artefacts.TableOfContents#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefacts.TableOfContents` ![[Magma.Artefacts.TableOfContents#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefacts.TableOfContents do
  use Magma.Artefact, matter: Magma.Matter.Text

  alias Magma.{Concept, Matter, Artefact}

  import Magma.View

  @impl true
  def name(concept), do: "#{concept.name} ToC"

  @impl true
  def version_prologue(%Artefact.Version{artefact: __MODULE__}) do
    assemble_button()
  end

  def assemble_button do
    button("Assemble sections", "magma.text.assemble", color: "blue")
  end

  def assemble_callout(version) do
    """
    The sections were already assembled. If you want to reassemble, please use the following Mix task:

    ```sh
    mix magma.text.assemble "#{version.name}"
    ```

    It will ask you to confirm any overwrites of files with user-provided content.
    """
    |> String.trim_trailing()
    |> callout()
  end

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    text_type.system_prompt_task(concept)
  end

  @impl true
  def request_prompt_task(%Concept{} = concept) do
    """
    Your task is to write an outline of "#{concept.name}".

    Please provide the outline in the following format:

    ```markdown
    ## Title of the first section

    Abstract: Abstract of the introduction.

    ## Title of the next section

    Abstract: Abstract of the next section.

    ## Title of the another section

    Abstract: Abstract of the another section.
    ```

    #{comment("Please don't change the general structure of this outline format. The section generator relies on an outline with sections.")}
    """
    |> String.trim_trailing()
  end

  @impl true
  def relative_base_path(%Concept{subject: matter}) do
    Matter.Text.relative_base_path(matter)
  end
end

```

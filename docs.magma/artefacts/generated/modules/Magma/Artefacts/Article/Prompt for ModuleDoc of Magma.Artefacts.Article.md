---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefacts.Article]]"
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

Final version: [[ModuleDoc of Magma.Artefacts.Article]]

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

# Prompt for ModuleDoc of Magma.Artefacts.Article

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

### ![[Magma.Artefacts.Article#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefacts.Article` ![[Magma.Artefacts.Article#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefacts.Article do
  use Magma.Artefact, matter: Magma.Matter.Text.Section

  alias Magma.{Concept, Matter}

  @relative_base_dir "article"

  @impl true
  def relative_base_path(%Concept{subject: %matter_type{} = matter}) do
    matter
    |> matter_type.relative_base_path()
    |> Path.join(@relative_base_dir)
  end

  @impl true
  def relative_version_path(%Concept{subject: %Matter.Text{} = text} = concept) do
    text
    |> Matter.Text.relative_base_path()
    |> Path.join("#{name(concept)}.md")
  end

  def relative_version_path(concept), do: super(concept)

  @impl true
  def name(%Concept{subject: %Matter.Text{}} = concept),
    do: "#{concept.name} (article)"

  def name(%Concept{subject: %Matter.Text.Section{}} = concept),
    do: "#{concept.name} (article section)"

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{type: text_type}} = concept) do
    do_system_prompt_task(concept, text_type)
  end

  def system_prompt_task(
        %Concept{subject: %Matter.Text.Section{main_text: %Matter.Text{type: text_type}}} =
          concept
      ) do
    do_system_prompt_task(concept, text_type)
  end

  defp do_system_prompt_task(%Concept{} = concept, text_type) do
    text_type.system_prompt_task(concept)
  end

  @impl true
  def request_prompt_task(%Concept{
        subject: %Matter.Text.Section{
          name: section_name,
          main_text: %Matter.Text{name: text_name}
        }
      }) do
    """
    Your task is to write the section "#{section_name}" of "#{text_name}".
    """
    |> String.trim_trailing()
  end
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.View]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:21
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

Final version: [[ModuleDoc of Magma.View]]

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

# Prompt for ModuleDoc of Magma.View

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


## Request

### ![[Magma.View#ModuleDoc prompt task|]]

### Description of the module `Magma.View` ![[Magma.View#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.View do
  alias Magma.{Concept, PromptResult, Artefact, Text, DocumentStruct}
  alias Magma.DocumentStruct.Section

  def link_to(document_or_target, section \\ nil)
  def link_to(%_{name: name}, title), do: link_to(name, title)
  def link_to(:title, :title), do: raise("invalid title")
  def link_to(target, :title), do: link_to(target, target)
  def link_to(target, nil) when is_binary(target), do: "[[#{target}]]"
  def link_to(target, section) when is_binary(target), do: "[[#{target}|#{section}]]"

  def link_to_concept(document, section \\ nil),
    do: document |> Concept.from() |> link_to(section)

  def link_to_prompt(document, section \\ nil),
    do: document |> Artefact.Prompt.from() |> link_to(section)

  def link_to_prompt_result(document, section \\ nil),
    do: document |> PromptResult.from() |> link_to(section)

  def link_to_version(document, section \\ nil),
    do: document |> Artefact.Version.from() |> link_to(section)

  def link_to_preview(document, section \\ nil),
    do: document |> Text.Preview.from() |> link_to(section)

  def transclude(document_or_target, section \\ nil)
  def transclude(%_{name: name}, title), do: transclude(name, title)
  def transclude(:title, :title), do: raise("invalid title")
  def transclude(target, :title), do: transclude(target, target)
  # We're adding the final '|' since Pandoc normalizes to this anyway
  def transclude(target, nil), do: "![[#{target}|]]"
  def transclude(target, section), do: "![[#{target}##{section}|]]"

  def transclude_concept(document, section \\ nil),
    do: document |> Concept.from() |> transclude(section)

  def transclude_prompt(document, section \\ nil),
    do: document |> Artefact.Prompt.from() |> transclude(section)

  def transclude_prompt_result(document, section \\ nil),
    do: document |> PromptResult.from() |> transclude(section)

  def transclude_version(document, section \\ nil),
    do: document |> Artefact.Version.from() |> transclude(section)

  def transclude_preview(document, section \\ nil),
    do: document |> Text.Preview.from() |> transclude(section)

  def include(document_or_section, subsection \\ nil, opts \\ [])
  def include(nil, _, _), do: nil

  def include(%Section{} = section, nil, opts) do
    section |> Section.to_string(opts) |> String.trim()
  end

  def include(%Section{} = section, subsection_path, opts) when is_list(subsection_path) do
    if subsection = get_in(section, subsection_path) do
      include(subsection, nil, opts)
    end
  end

  def include(%Section{} = section, subsection, opts) do
    if subsection = Section.section_by_title(section, subsection) do
      include(subsection, nil, opts)
    end
  end

  def include(%Concept{} = concept, nil, opts) do
    concept
    |> Concept.description_section()
    |> include(nil, opts)
  end

  def include(%Concept{} = concept, :title, opts) do
    include(concept, concept.title, opts)
  end

  def include(%Concept{} = concept, subsection, opts) do
    concept
    |> DocumentStruct.section_by_title(subsection)
    |> include(nil, opts)
  end

  def include(%_document_type{content: content}, subsection, opts) do
    case DocumentStruct.parse(content) do
      {:ok, document_struct} ->
        subsection =
          if subsection in [:title, nil],
            do: DocumentStruct.title(document_struct),
            else: subsection

        cond do
          subsection == :all ->
            # DocumentStruct.to_string() does not support opts yet
            document_struct |> DocumentStruct.to_string() |> String.trim()

          section = DocumentStruct.section_by_title(document_struct, subsection) ->
            include(section, nil, opts)

          true ->
            nil
        end

      {:error, error} ->
        raise error
    end
  end

  def comment(text) do
    """
    <!--
    #{text}
    -->
    """
    |> String.trim_trailing()
  end

  def callout(text, type \\ "info") do
    """
    >[!#{type}]
    >#{String.replace(text, "\n", "\n>")}
    """
    |> String.trim_trailing()
  end

  def button(label, command, opts \\ []) do
    """
    ```button
    name #{label}
    type command
    action Shell commands: Execute: #{command}
    color #{opts[:color] || "default"}
    ```
    """
    |> String.trim_trailing()
  end

  def delete_current_file_button do
    """
    ```button
    name Delete
    type command
    action Delete current file
    color red
    ```
    """
    |> String.trim_trailing()
  end

  def yaml_list(list) do
    "[" <> (list |> List.wrap() |> Enum.join(", ")) <> "]"
  end

  def yaml_nested_map(map) do
    map |> Map.from_struct() |> Jason.encode!()
  end

  def prompt_results_table do
    """
    ```dataview
    TABLE
    	tags AS Tags,
    	magma_generation_type AS Generator,
    	magma_generation_params AS Params
    WHERE magma_prompt = [[]]
    ```
    """
    |> String.trim_trailing()
  end
end

```

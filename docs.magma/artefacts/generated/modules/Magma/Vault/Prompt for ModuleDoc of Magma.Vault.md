---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault]]"
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

Final version: [[ModuleDoc of Magma.Vault]]

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

# Prompt for ModuleDoc of Magma.Vault

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

##### `Magma.Vault.Initializer` ![[Magma.Vault.Initializer#Description|]]

##### `Magma.Vault.BaseVault` ![[Magma.Vault.BaseVault#Description|]]

##### `Magma.Vault.CodeSync` ![[Magma.Vault.CodeSync#Description|]]


## Request

### ![[Magma.Vault#ModuleDoc prompt task|]]

### Description of the module `Magma.Vault` ![[Magma.Vault#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Vault do
  alias Magma.Document
  alias Magma.Vault.Index

  @default_path "docs.magma"
  @concept_path_prefix "concepts"
  @artefact_path_prefix "artefacts"
  @artefact_generation_path_prefix Path.join(@artefact_path_prefix, "generated")
  @artefact_version_path_prefix Path.join(@artefact_path_prefix, "final")

  @template_path_prefix "templates"
  @custom_prompt_template_name "custom_prompt.md"

  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  def template_path(segments \\ nil), do: path([@template_path_prefix | List.wrap(segments)])

  def custom_prompt_template_path, do: template_path(@custom_prompt_template_name)

  def concept_path(segments \\ nil), do: path([@concept_path_prefix | List.wrap(segments)])

  def artefact_generation_path(segments \\ nil),
    do: path([@artefact_generation_path_prefix | List.wrap(segments)])

  def artefact_version_path(segments \\ nil),
    do: path([@artefact_version_path_prefix | List.wrap(segments)])

  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync

  defdelegate index(document), to: Magma.Vault.Index, as: :add

  def document_path(name_or_path) do
    if File.exists?(name_or_path) do
      name_or_path
    else
      Index.get_document_path(name_or_path)
    end
  end

  def document_type(name_or_path) do
    if path = document_path(name_or_path) do
      with {:ok, metadata, _body} <- YamlFrontMatter.parse_file(path) do
        magma_type = metadata["magma_type"]

        if document_type = Document.type(magma_type) do
          {:ok, document_type}
        else
          {:error, "invalid magma_type in #{path}: #{inspect(magma_type)}"}
        end
      end
    else
      {:error, Magma.DocumentNotFound.exception(name: name_or_path)}
    end
  end
end

```

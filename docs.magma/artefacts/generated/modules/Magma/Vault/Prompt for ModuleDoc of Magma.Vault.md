---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-17 14:51:40
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

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

You have two tasks to do based on the given implementation of the module and your knowledge base:  
  
1. generate the content of the `@doc` strings of the public functions
2. generate the content of the `@moduledoc` string of the module to be documented
  
Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.  

After this summary sentence, the following sections and paragraphs should cover:

- What's the purpose of this module/function?
- What role does this module play in the overall context of the system/module?
- For moduledocs: What are the main function(s) of this module?
- If possible, an example usage of the module in an "Example" section.
- Configuration options (if there are any)
- What else is 
  
The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block):  
  
```markdown  
## Function docs  
  
### `function/1`  

Summary sentence

Body

## Moduledoc
  
Summary sentence

Body
```

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]

##### `Magma.Vault.BaseVault` ![[Magma.Vault.BaseVault#Description|]]

#### `Magma.Document` ![[Magma.Document#Description|]]

#### `Magma.Vault.BaseVault`![[Magma.Vault.BaseVault#Description|]]

#### Vault initialization ![[Magma vault creation#Vault initialization]]

#### `Magma.Vault.CodeSync` ![[Mix.Tasks.Magma.Vault.Sync.Code#Description|]]


## Request

![[Magma.Vault#ModuleDoc prompt task|]]

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

  @doc """
  Returns the application configured path to the vault.

  Unless specified otherwise, the path is the `#{@default_path}` directory
  inside the project directory.

  It can be changed with in your `config.exs` file like this:

      config :magma,
        dir: "custom_dir"

  Note, that this configuration should be environment-independent.
  Unless you're working on Magma itself, you don't want a test-specific vault,
  since the vault collects knowledge about your code in its entirety.
  """
  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()

  @doc """
  TODO:
  """
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  @doc """
  TODO:
  """
  def template_path(segments \\ nil), do: path([@template_path_prefix | List.wrap(segments)])

  def custom_prompt_template_path, do: template_path(@custom_prompt_template_name)

  @doc """
  The vault relative path for `Magma.Concept` documents.
  """
  def concept_path(segments \\ nil), do: path([@concept_path_prefix | List.wrap(segments)])

  def artefact_generation_path(segments \\ nil),
    do: path([@artefact_generation_path_prefix | List.wrap(segments)])

  def artefact_version_path(segments \\ nil),
    do: path([@artefact_version_path_prefix | List.wrap(segments)])

  @doc """
  Creates and initializes a new vault.
  """
  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync

  @doc """
  TODO
  """
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

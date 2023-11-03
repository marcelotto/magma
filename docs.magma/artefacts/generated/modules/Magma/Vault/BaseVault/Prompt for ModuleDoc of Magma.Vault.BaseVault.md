---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.BaseVault]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-18 04:04:14
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

Final version: [[ModuleDoc of Magma.Vault.BaseVault]]

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

# Prompt for ModuleDoc of Magma.Vault.BaseVault

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
- Configuration options (if there are any)

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

##### `Magma.Vault` ![[Magma.Vault#Description|]]

#### `Magma.Vault` ![[Magma.Vault#Description|]]

#### ![[Magma vault creation#Vault initialization]]


## Request

![[Magma.Vault.BaseVault#ModuleDoc prompt task|]]

### Description of the module `Magma.Vault.BaseVault` ![[Magma.Vault.BaseVault#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Vault.BaseVault do
  use Magma

  @path :code.priv_dir(:magma) |> Path.join("base_vault")
  @default_theme :default

  @type theme :: atom

  @doc """
  Returns the path to a base vault.

  Either the name of one of predefined base vault in the `priv/base_vault`
  directory of Magma can be used or the path to a custom local base vault.
  If no base vault is given the default base vault is used.
  """
  def path(path_or_theme \\ nil)
  def path(nil), do: path(@default_theme)
  def path(theme) when is_atom(theme), do: Path.join(@path, to_string(theme))
  def path(path) when is_binary(path), do: path

  @doc """
  Returns the path to a base vault and raises an error when the given base vault does not exist.

  Accepts the same arguments as `path/1`.
  """
  def path!(path_or_theme \\ nil) do
    path = path(path_or_theme)

    if File.exists?(path) do
      path
    else
      raise "No base vault found at #{path}"
    end
  end
end

```

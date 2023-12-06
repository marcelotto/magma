---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.BaseVault]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:55
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

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Vault.BaseVault#Context knowledge|]]


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

  Either the atom name of one of the predefined base vault in the `priv/base_vault`
  directory of Magma can be used or the path to a custom local base vault.
  If no base vault is given the default base vault is used.

      # Get path for the default base vault
      Magma.Vault.BaseVault.path()

      # Get path for a predefined base vault
      Magma.Vault.BaseVault.path(:custom_theme)

      # Get path for a custom base vault
      Magma.Vault.BaseVault.path("/path/to/custom/base/vault")

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

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.Migration]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: 2023-12-06 16:35:56
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

Final version: [[ModuleDoc of Magma.Vault.Migration]]

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

# Prompt for ModuleDoc of Magma.Vault.Migration

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Vault.Migration#Context knowledge|]]


## Request

![[Magma.Vault.Migration#ModuleDoc prompt task|]]

### Description of the module `Magma.Vault.Migration` ![[Magma.Vault.Migration#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Vault.Migration do
  @moduledoc """
  Migration of Magma vaults to be compatible with newer versions.

  This module implements the general migration logic for `Magma.Vault`s
  created with older versions of Magma, so they can be updated to work with
  a newer version. It provides functionality to check the vault's version
  against the required version and apply any necessary migrations, implemented
  dedicated modules for specific versions. This process is crucial for
  maintaining consistency and functionality as the Magma project evolves.
  """

  alias Magma.Vault

  @magma_version_requirement "~> #{%Version{Magma.version() | patch: 0, pre: []}}"
  def magma_version_requirement, do: @magma_version_requirement

  @doc """
  Applies all necessary migrations to update the vault for a newer version of Magma.
  """
  def migrate(), do: Vault.Version.load() |> migrate()

  defp migrate(version_string) when is_binary(version_string) do
    with {:ok, version} <- Version.parse(version_string) do
      migrate(version)
    end
  end

  defp migrate(%Version{} = vault_version) do
    if Version.match?(vault_version, @magma_version_requirement) do
      :ok
    else
      with {:ok, version} <- do_migrate(vault_version),
           :ok <- Vault.Version.save(version) do
        migrate(version)
      end
    end
  end

  defp do_migrate(%Version{major: 0, minor: 1} = version),
    do: Vault.Migration.V0_2.migrate(version)
end

```

---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.Version]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
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

Final version: [[ModuleDoc of Magma.Vault.Version]]

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

# Prompt for ModuleDoc of Magma.Vault.Version

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Vault.Version#Context knowledge|]]


## Request

![[Magma.Vault.Version#ModuleDoc prompt task|]]

### Description of the module `Magma.Vault.Version` ![[Magma.Vault.Version#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Vault.Version do
  @moduledoc """
  Manages the versioning of the Magma vault.

  The `Magma.Vault.Version` module provides functionality to handle the
  versioning of the `Magma.Vault` by managing a version file within the vault.
  This is crucial for ensuring compatibility between the vault and the
  version of Magma being used, and for performing migrations when upgrading
  to a new version of Magma.
  """

  @version_file ".VERSION"

  @doc """
  Returns the path to the version file in the Magma vault.
  """
  def file, do: Magma.Config.path(@version_file)

  @doc """
  Loads and returns the Magma vault version from the version file.

  This function reads the version information from the `.VERSION` file within
  the Magma vault. If the version file exists, it parses the version string
  into a `Version` struct. If the file does not exist, it defaults to version
  "0.1.0".
  """
  def load do
    if File.exists?(file()) do
      file() |> File.read!() |> String.trim() |> Version.parse!()
    else
      Version.parse!("0.1.0")
    end
  end

  @doc """
  Saves the given version to the version file in the Magma vault.
  """
  def save(version)

  def save(version_string) when is_binary(version_string) do
    with {:ok, version} <- Version.parse(version_string) do
      save(version)
    end
  end

  def save(%Version{} = version) do
    File.write(file(), to_string(version))
  end
end

```

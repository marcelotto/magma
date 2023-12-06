---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.Version]]"
magma_draft: "[[Generated ModuleDoc of Magma.Vault.Version (2023-12-04T14:51:41)]]"
created_at: 2023-12-04 14:53:05
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Vault.Version

## Function docs

### `file/0`

Returns the path to the version file in the Magma vault.

This function provides the absolute path to the `.VERSION` file which stores the version of Magma that the vault is intended to work with. The path is determined using the configuration settings for the vault's location.

### `load/0`

Loads and returns the Magma vault version from the version file.

This function reads the version information from the `.VERSION` file within the Magma vault. If the version file exists, it parses the version string into a `Version` struct. If the file does not exist, it defaults to version "0.1.0".

### `save/1`

Saves the given version to the version file in the Magma vault.

This function takes a `Version` struct and writes its string representation to the `.VERSION` file in the Magma vault. This is typically used to update the vault to a new version of Magma.

Example:

```elixir
version = Version.parse!("1.2.3")
Magma.Vault.Version.save(version)
```

## Moduledoc

Manages the versioning of the Magma vault.

The `Magma.Vault.Version` module provides functionality to handle the versioning of the Magma vault by managing a version file. This is crucial for ensuring compatibility between the vault and the version of Magma being used, and for performing migrations when upgrading to a new version of Magma.

The main functions of this module are to load the current version of the vault from a file, and to save a new version to the file. The version file is named `.VERSION` and is located in the root of the Magma vault directory. If the version file does not exist, the module will default to version "0.1.0".

It is important to keep the vault version up to date with the Magma version to prevent issues with compatibility and to make use of the latest features.

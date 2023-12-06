---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.Migration]]"
magma_draft: "[[Generated ModuleDoc of Magma.Vault.Migration (2023-12-04T13:57:03)]]"
created_at: 2023-12-04 13:58:57
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Vault.Migration

## Moduledoc

Migration of Magma vaults to be compatible with newer versions.

This module ensures that `Magma.Vault`s created with older
versions of Magma can be updated to work with a newer version. It
provides functionality to check the vault's version against the required version
and apply any necessary migrations. This process is crucial for maintaining
consistency and functionality as the Magma project evolves.


---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault.BaseVault]]"
magma_draft: "[[Generated ModuleDoc of Magma.Vault.BaseVault (2023-10-18T04:02:46)]]"
created_at: 2023-10-18 13:08:15
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Vault.BaseVault

## Moduledoc

Provides utilities to interact with predefined and custom base vaults.

A base vault is a preconfigured Obsidian vault that serves as a template when initializing a new Magma vault.


### Creating a new base vault

If you are looking to create a new base vault (either a local one or as a contribution to the Magma project), ensure you include the required plugins from the default base vault:

- [Buttons](https://github.com/shabegom/buttons) 
- [Shell commands](https://github.com/Taitava/obsidian-shellcommands) 
- [QuickAdd](https://github.com/chhoumann/quickadd) 
- [Dataview](https://github.com/blacksmithgu/obsidian-dataview) 

Also, it's vital to copy the configurations of the Shell Commands and QuickAdd plugins, as they include the integration with the respective Magma mix tasks. 


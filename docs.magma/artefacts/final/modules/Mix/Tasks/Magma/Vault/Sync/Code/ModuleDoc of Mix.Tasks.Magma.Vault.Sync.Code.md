---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Vault.Sync.Code]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Vault.Sync.Code (2023-10-29T14:19:58)]]"
created_at: 2023-10-29 14:23:45
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Vault.Sync.Code

## Moduledoc

A Mix task for syncing the module documents in the Magma vault with the ones in the codebase.

This Mix task is used to create corresponding Magma documents for all public and non-ignored modules in the codebase. This is particularly useful when new modules have been added after the initial vault creation. The task can be run from the command line using `mix magma.vault.sync.code`.

A module is considered ignored and will be skipped in the sync process:

- If it has a `# Magma pragma: ignore` comment at the beginning of its source code, or
- If it is marked as hidden (e.g. with `@moduledoc false`) and does not have a  `# Magma pragma: include` comment at the beginning of its source code.

For each non-ignored module, the following Magma documents are created (unless they already exist):

- `Magma.Concept`
- `Magma.Artefact.Prompt`s for all `Magma.Artefact`s of modules, e.g. a prompt for `Magma.Artefacts.ModuleDoc`

### Configuration

A set of tags to be added on all generated documents can be configured with the `default_tags` application key. This can be useful for separating Magma documents from other documents in your vault. e.g. to filter them.

``` elixir
config :magma,  
  default_tags: ["magma-vault"]
```

### Command line options

- `--force` - Forces the overwrite of all existing documents without user confirmation
- `--all` - Includes modules for already existing documents in the synchronization process 

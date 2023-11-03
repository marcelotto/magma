---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Vault.Init]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Vault.Init (2023-10-29T14:07:41)]]"
created_at: 2023-10-29 14:09:46
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Vault.Init


## Moduledoc

A Mix task for initializing the Magma vault directory.

This task is responsible for creating a new Magma vault for your project. The vault is initialized with a given project name, and optionally with a BaseVault which is an Obsidian vault preconfigured with Obsidian themes and plugins. If no BaseVault is specified, the default BaseVault is used. The vault is stored by default under the `docs.magma` directory within your project, this can be configured in the `config.exs` file.

During initialization, the task creates a concept document and artefact prompt for the project, concept documents and artefact prompts for all public modules of the project and for their moduledocs via a code sync, and a custom prompt template.

### Example

```sh
$ mix magma.vault.init "Your project name"
```

### Configuration

The location where the Magma vault is stored can be changed by setting the `dir` application key in the `magma` app in `config.exs`.

``` elixir
config :magma,  
  dir: "your_magma_vault/"
```


A set of tags to be added on all generated documents can be configured with the `default_tags` application key. This can be useful for separating Magma documents from other documents in your vault. e.g. to filter them.

``` elixir
config :magma,  
  default_tags: ["magma-vault"]
```

### Command line options

- `--force`: If specified, forces the initialization even if a Magma vault already exists.
- `--base-vault`: The name of a BaseVault to be used for initialization. If not specified, the default BaseVault is used.
- `--base-vault-path`: The local path to a self-defined BaseVault to be used for initialization.
- `--no-code-sync`: If specified, the code sync that creates concept documents and artefact prompts for all public modules of the project is skipped.

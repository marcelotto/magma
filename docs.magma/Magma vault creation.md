# Magma vault creation

A new Magma vault for your project can be created with the `Mix.Tasks.Magma.Vault.Init` Mix task:

```sh
$ mix magma.vault.init "Name of your project" [BaseVaultName]
```

(or programmatically via the underlying `Magma.Vault.create/3` function).

A project name must be specified as the first mandatory parameter.  
  
As a second optional argument the name of a BaseVault can be specified.
A BaseVault is an Obsidian vault preconfigured with Obsidian themes and plugins that is used as a base when initializing a Magma vault. Instead of the name of one of the BaseVaults delivered with Magma, the local path to a self-defined BaseVault can also be specified. However, it must be ensured that the necessary plug-ins and their configuration are taken from the default BaseVault. If no BaseVault is specified, the default BaseVault is used.  

By default, a Magma vault is stored under the `docs.magma` directory within your project, which can be changed by setting it in the `dir` application key of the `magma` app in `config.exs`:

```elixir
config :magma,  
  dir: "your_magma_vault/"
```

What is created during initialization:

- A concept document and artefact prompt for the project
- Concept documents and artefact prompts for all public modules of the project and  for their moduledocs via a code sync
- a custom prompt template

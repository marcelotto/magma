TODO:

- add option to set artefact typed to be generated when we have multiple
	- How do we handle artefacts with params?

# Code sync

If you want to add documents for modules that were created after the initial vault creation, you can do so with the `Mix.Tasks.Magma.Vault.Sync.Code` Mix task (or programmatically via the underlying  `Magma.Vault.sync/1` function):

```sh
$ mix magma.vault.sync.code
```

A code sync creates corresponding documents for the generation of Magma artefacts  for all public and non-ignored modules. A module is ignored  
  
- if it has a `# Magma pragma: ignore` comment at the beginning of its source code, or 
- if it is marked as hidden (e.g. with `@moduledoc false`) and does not have a  
  `# Magma pragma: include` comment at the beginning of its source code.


For each of non-ignored module one the following `Magma.Document`s are created (unless they exist already):

- a `Magma.Concept` 
- `Magma.Artefact.Prompt`s for all `Magma.Artefact`s  for `Magma.Matter.Module`  (as specified by `Magma.Matter.Module.artefacts/0`), e.g. a prompt for `Magma.Artefacts.ModuleDoc`)

Available options:

- `:all` (default: `false`) - when set to `true` also syncs modules for already existing documents
- `force` (default: `false`) - when set to `true` overwrites all existing documents without asking the user


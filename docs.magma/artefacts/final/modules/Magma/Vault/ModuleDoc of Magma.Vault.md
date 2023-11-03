---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault]]"
magma_draft: "[[Generated ModuleDoc of Magma.Vault (2023-10-17T14:52:51)]]"
created_at: 2023-10-17 15:38:49
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Vault

## Function docs  

### `sync/1`  

Synchronizes the Magma vault with the codebase.

This function delegates its execution to `Magma.Vault.CodeSync`. It ensures that the documents in the Magma vault stay updated and in sync with the project's codebase.

## Moduledoc

Represents a specialized Obsidian vault directory with folders for the Magma-specific documents.

The `Magma.Vault` module serves as a representation and utility module for a Magma vault - a specialized Obsidian vault that resides in an Elixir project. This vault is more than just a collection of Markdown documents; it houses Magma documents, which are special kinds of Markdown documents with specific paths and purposes. The vault itself can be stored by default in the `docs.magma/` directory of an Elixir project but can be reconfigured as needed (see `path/0)`.

Main functions of this module include:

- Retrieving paths within the vault, like the base path, template paths, concept paths, etc.
- Creating and initializing a new vault (`create/3`).
- Synchronizing the vault with the project's codebase (`sync/1`).
- Indexing documents by name (`index/1`).
- Fetching details of documents, such as their path (`document_path/1`) or type (`document_type/1`) .

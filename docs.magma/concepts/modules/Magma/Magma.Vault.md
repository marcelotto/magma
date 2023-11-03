---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:15
tags: [magma-vault]
aliases: []
---
# `Magma.Vault`

## Description

A Magma vault is a special kind of Obsidian vault. It is stored by default inside of the `docs.magma` directory of an Elixir project.  With the `magma.dir` application configuration key it can be configured to be stored in another directory. Usually the Magma vault is kept under version control along with code.

Besides normal Obsidian Markdown documents with knowledge snippets about the project, it consists of some more specialized kinds of Markdown documents, called Magma documents (which are nevertheless still normal Markdown documents), each which specify a path scheme for instances of these document types within the vault.

To be able to access the documents within the vault just by name (independent of their directory), the documents are indexed with the `index/1` function. At application start all files in the vault directory are indexed automatically. 

<!--
TODO:

- Directory structure should be documented in document types
	- for document type ...
	- for custom files ...
	- templates ...
-->


# Context knowledge

## `Magma.Document` ![[Magma.Document#Description]]
## `Magma.Vault.BaseVault`![[Magma.Vault.BaseVault#Description]]
## Vault initialization  ![[Magma vault creation#Vault initialization]]
## `Magma.Vault.CodeSync` ![[Mix.Tasks.Magma.Vault.Sync.Code#Description]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Vault]]
- Final version: [[ModuleDoc of Magma.Vault]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Vault` according to its description and code in the knowledge base below.

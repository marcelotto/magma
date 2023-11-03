---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: []
---
# `Magma.Artefact.Version`

## Description

A Magma artefact version document is a concrete realization of a Magma artefact. It is created when the user selects one of the Magma prompt result documents (created by executing a Magma artefact prompt). This selection by the user results in a new Magma artefact version document being created and the contents of the selected Prompt result being copied for it. The user can then edit and finalize this draft version. Depending on the artefact type, further operations can then be performed on the completed version.  
  
  
# Context knowledge

### Magma artefact model ![[Magma artefact model#Description]]
 ![[Magma artefact model#Sequence diagram]]
### `Magma.Matter` ![[Magma.Matter#Description]]

### `Magma.Artefact` ![[Magma.Artefact#Description]]

### `Magma.Concept` ![[Magma.Concept#Description]]

### `Magma.Artefact.Prompt` ![[Magma.Artefact.Prompt#Description]]
### `Magma.PromptResult` ![[Magma.PromptResult#Description]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Artefact.Version]]
- Final version: [[ModuleDoc of Magma.Artefact.Version]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Artefact.Version` according to its description and code in the knowledge base below.

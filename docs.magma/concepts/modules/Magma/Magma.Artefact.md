---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: []
---
# `Magma.Artefact`

## Description

Magma artefacts are the elements of the [[Magma artefact model]] that represent the things we want to generate for some Magma matter. 

`Magma.Artefact` is a behaviour for the different types of such artefacts.

Each artefact type: 

- is defined under the namespace `Magma.Artefacts`
- defines functions for the artefact-specific parts of the paths of concept and prompt documents, e.g. some subfolders in which all documents about this type of artefact should be grouped
- defines various functions specifying texts for different parts of the concept and prompt documents

<!-- 
TODO: when artefact becomes a struct again
defines a struct with additional fields besides the mandatory `:name`  field of every artefact type
-->

Magma comes with the following implemented `Magma.Artefact` types:

- `Magma.Artefacts.ModuleDoc`
- `Magma.Artefacts.README`
- `Magma.Artefacts.Article`
- `Magma.Artefacts.TableOfContents` 



# Context knowledge

### Magma artefact model ![[Magma artefact model#Description]]
 ![[Magma artefact model#Sequence diagram]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Artefact]]
- Final version: [[ModuleDoc of Magma.Artefact]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Artefact` according to its description and code in the knowledge base below.

Conclude with a list of the `Magma.Artefact` types implemented in Magma.

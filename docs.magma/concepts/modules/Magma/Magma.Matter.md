---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:13
tags: [magma-vault]
aliases: []
---
# `Magma.Matter`

## Description

Magma matter are the elements of the [[Magma artefact model]] that represent the subject of the concept documents and by that, the subject of the artefact generated from the concept. 

`Magma.Matter` is a behaviour for the different types of such subject matter.

Each matter type: 

- is defined under the namespace `Magma.Matter`
- defines a struct with additional fields besides the mandatory `:name`  field of every matter type
- defines which kinds of Magma artefacts are available for this matter type (`artefacts/0` callback)
- defines functions for the matter-specific parts of the path of concept and prompt documents, e.g. some subfolders in which all documents about this type of matter should be grouped
- defines various functions specifying texts for different parts of the concept and prompt documents

Magma comes with the following implemented `Magma.Matter` types:

- `Magma.Matter.Module`
- `Magma.Matter.Project`
- `Magma.Matter.Text` which is a complex matter consisting of multiple `Magma.Matter.Text.Section`s



# Context knowledge

### Magma artefact model ![[Magma artefact model#Description]]
![[Magma artefact model#Sequence diagram]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Matter]]
- Final version: [[ModuleDoc of Magma.Matter]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Matter` according to its description and code in the knowledge base below.


---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:11
tags: [magma-vault]
aliases: []
---
# `Magma.Concept`

## Description
  
A Magma concept document is the basic Magma document for the generation of concrete Magma artefact versions. It contains all the content contributed by the user to the generation, i.e.  
  
- the descriptions of the subject matter (e.g. a module or the project) in a "Description" section
- the background knowledge necessary for the understanding of the subject matter or the generation of the artefacts in a "Context knowledge" section by an LLM
- the task description to be used for the LLM prompt to generate the various artefacts for the corresponding matter, in appropriate sections for the artefacts.
  
Although the basic structure of any concept document is given Matter-independently, a Magma matter type may define further predefined content and sections for the concept document.  


# Context knowledge

### Magma artefact model ![[Magma artefact model#Description]]
 ![[Magma artefact model#Sequence diagram]]

### `Magma.Matter` ![[Magma.Matter#Description]]
### `Magma.Document` ![[Magma.Document#Description]]


### `Magma.Artefact` ![[Magma.Artefact#Description]]

### `Magma.Artefact.Prompt` ![[Magma.Artefact.Prompt#Description]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Concept]]
- Final version: [[ModuleDoc of Magma.Concept]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Concept` according to its description and code in the knowledge base below.

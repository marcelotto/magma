---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: []
---
# `Magma.Artefact.Prompt`

## Description

A Magma artefact prompt is a special form of a [[Magma.Prompt|Magma prompt]] document. Unlike these documents used for custom prompts, the Magma artefact prompt document does not contain any content contributed by the user directly. Instead, it is a composition of transclusions of the contents of the Magma concept document defined by the Magma artefact type. 

The execution of the Magma prompt document, however, is otherwise done in the same way as for any `Magma.Prompt` document, in particular a `Magma.PromptResult` is also created for this purpose. However, this provides the option of selecting the result as the basis for the final Magma artefact version by means of an additional button in the prologue.

# Context knowledge

### Magma artefact model ![[Magma artefact model#Description]]
 ![[Magma artefact model#Sequence diagram]]

### `Magma.Matter` ![[Magma.Matter#Description]]

### `Magma.Artefact` ![[Magma.Artefact#Description]]

### Magma-Transclusion-Resolution ![[Magma-Transclusion-Resolution#Description]]
### `Magma.Concept` ![[Magma.Concept#Description]]


### `Magma.Prompt` ![[Magma.Prompt#Description]]
### `Magma.PromptResult` ![[Magma.Prompt#Description]]



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Artefact.Prompt]]
- Final version: [[ModuleDoc of Magma.Artefact.Prompt]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Artefact.Prompt` according to its description and code in the knowledge base below.

---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:12
tags: [magma-vault]
aliases: []
---
# `Magma.DocumentStruct`

## Description

A `Magma.DocumentStruct` is an Elixir struct for the contents of a Markdown document as an AST based on the Pandoc AST. However, unlike the normal Pandoc AST the content is structured according to the section nesting, i.e. a DocumentStruct consists of:

- the prologue, i.e. the header-less text before the first section 
- all sections of level 1 (which consist of section of level 2 and so on)

It has this structure in order to be able to realize the "transclusion resolution" feature, which is essential for the prompt generation in Magma. The actual implementation of the core functions of the DocumentStruct takes place, however, in `Magma.DocumentStruct.Section`, while here, as outer wrapper around the recursive `Section` structure, essentially only to their functions is delegated.  

### Transclusion resolution ![[Magma-Transclusion-Resolution#Description]]

# Context knowledge




# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.DocumentStruct]]
- Final version: [[ModuleDoc of Magma.DocumentStruct]]

### ModuleDoc prompt task

Generate documentation for module `Magma.DocumentStruct` according to its description and code in the knowledge base below.

In the documentation of the `resolve_transclusions/1` function include a description of the transclusion resolution mechanism.

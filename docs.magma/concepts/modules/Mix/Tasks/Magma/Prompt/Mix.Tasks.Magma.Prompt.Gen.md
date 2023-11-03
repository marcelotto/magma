---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:16
tags: [magma-vault]
aliases: []
---
# `Mix.Tasks.Magma.Prompt.Gen`

## Description

Generate artefact prompt documents and custom prompt documents.

This task has two modes of operation:

- Either you provide a single argument with the name of the prompt to generate a custom prompt document
```sh
$ mix magma.prompt.gen "Prompt for something"
```
- Or you provide two arguments, the first being the name of a concept and the second the artefact type, where the artefact type is the last part of the `Magma.Artefacts.X` artefact type, e.g. `ModuleDoc` or `Readme`.
	- Note, that this is usually not necessary, since by default all artefact prompts for the matter type of a concept are already created on the creation of the concept document and when you only want to update the artefact the `Mix.Tasks.Magma.Prompt.Update` Mix task can be used.
```sh
$ mix magma.prompt.gen "Some.Module" ModuleDoc
```

When the `--force` switch is set, existing documents are overwritten without asking for permission first.

There are no notable configuration options.

# Context knowledge

### Magma documents ![[Magma.Document#Description]]

### Magma concept documents ![[Magma.Concept#Description]]
### Magma custom prompt documents ![[Magma.Prompt#Description]]
### Magma artefact prompt documents ![[Magma.Artefact.Prompt#Description]]



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Gen]]
- Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Gen]]

### ModuleDoc prompt task

Generate documentation for module `Mix.Tasks.Magma.Prompt.Gen` according to its description and code in the knowledge base below.

![[Prompt snippets#Mix task moduledoc]]

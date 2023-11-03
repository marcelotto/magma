---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:11
tags: [magma-vault]
aliases: []
---
# `Magma.Document`

## Description

Magma documents are the Obsidian Markdown documents in a Magma vault with a special semantics for Magma.

The `Magma.Document` module 

- is a behaviour for the definition of the different kinds of document types and their specific semantics
- defines the common set of fields and logic shared between all document types

Each Magma document type: 

- defines additional fields for the fulfilment of its tasks (in addition to the fields of each document type) and the serialization and deserialization logic for these fields in the Obsidian Markdown files (mostly in its YAML front matter)
- defines a path scheme that determines where instances of this type are stored

Magma comes with the following implemented `Magma.Document` types:

- `Magma.Concept`
- `Magma.Prompt`
- `Magma.PromptResult`
- `Magma.Artefact.Prompt`
- `Magma.Artefact.Version`
- `Magma.Text.Preview`

# Context knowledge

## `Magma.Vault` ![[Magma.Vault#Description]]
## `Magma.DocumentStruct` ![[Magma.DocumentStruct#Description]]
## `Magma.Concept` ![[Magma.Concept#Description]]  
  
## `Magma.Prompt` ![[Magma.Prompt#Description]]  
  
## `Magma.PromptResult` ![[Magma.PromptResult#Description]]  
  
## `Magma.Artefact.Prompt` ![[Magma.Artefact.Prompt#Description]]  
  
## `Magma.Artefact.Version` ![[Magma.Artefact.Version#Description]]  
  
## `Magma.Text.Preview` ![[Magma.Text.Preview#Description]]

# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Document]]
- Final version: [[ModuleDoc of Magma.Document]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Document` according to its description and code in the knowledge base below.

Conclude with a list of the `Magma.Document` types implemented in Magma.

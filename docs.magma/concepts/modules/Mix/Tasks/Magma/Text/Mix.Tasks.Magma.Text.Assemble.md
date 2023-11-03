---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:16
tags: [magma-vault]
aliases: []
---
# `Mix.Tasks.Magma.Text.Assemble`

## Description

Generates the section documents from the final table of contents of a text.

When the final artefact version document for the `Magma.Artefacts.TableOfContents` of a text was created, this task will create the concept and artefact prompt documents of the sections of the text and assemble the preview document.

```sh
mix magma.text.assemble "Name of ToC document"
```

Options:

- `--force` - When set, this option allows the task to overwrite existing documents without asking for permission first.


# Context knowledge



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Mix.Tasks.Magma.Text.Assemble]]
- Final version: [[ModuleDoc of Mix.Tasks.Magma.Text.Assemble]]

### ModuleDoc prompt task

Generate documentation for module `Mix.Tasks.Magma.Text.Assemble` according to its description and code in the knowledge base below.

![[Prompt snippets#Mix task moduledoc]]
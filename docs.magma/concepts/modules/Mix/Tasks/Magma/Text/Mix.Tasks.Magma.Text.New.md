---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:17
tags: [magma-vault]
aliases: []
---
# `Mix.Tasks.Magma.Text.New`

## Description

Generates a new text concept and artefact prompts.

The initial documents for a new text are created with this Mix task where the first argument is the title of your text, followed by an optional text type:

```sh
$ mix magma.text.new "Example User Guide" UserGuide
```

where the text types the last part of text type modules of the form `Magma.Matter.Texts.X`. The text type determines the details of the system prompt of the artefact prompts. Currently, there is only one text implemented in this early stage of development, the `UserGuide` type. 

If no text type is given a minimal generic system prompt is used which can be refined for the users needs. 

When the `--force` switch is set, existing documents are overwritten without asking for permission first.

# Context knowledge



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Mix.Tasks.Magma.Text.New]]
- Final version: [[ModuleDoc of Mix.Tasks.Magma.Text.New]]

### ModuleDoc prompt task

Generate documentation for module `Mix.Tasks.Magma.Text.New` according to its description and code in the knowledge base below.

![[Prompt snippets#Mix task moduledoc]]
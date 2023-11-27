---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-11-25 22:37:13
tags: [magma-vault]
aliases: []
---
# `Mix.Tasks.Magma.Text.Type.New`

## Description


Generates a new text type.

The config document for a new text type is created with this Mix task where the first argument is the name of the text type which must a valid module name, followed by an optional text type label:

```sh
$ mix magma.text.type.new SomeTextType "Some text type"
```

When the `--force` switch is set, existing documents are overwritten without asking for permission first.


# Context knowledge



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Mix.Tasks.Magma.Text.Type.New]]
- Final version: [[ModuleDoc of Mix.Tasks.Magma.Text.Type.New]]

### ModuleDoc prompt task

Generate documentation for module `Mix.Tasks.Magma.Text.Type.New` according to its description and code in the knowledge base below.

![[Prompt snippets#Mix task moduledoc]]

---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:16
tags: [magma-vault]
aliases: []
---
# `Mix.Tasks.Magma.Prompt.Exec`

## Description

Executes the given prompt either manually or according to generation specified within the prompt.

Without any further arguments the prompt is executed according to the `magma_generation_type` and `magma_generation_params` in the YAML frontmatter of the prompt document.

```sh
$ mix magma.prompt.exec "Name of prompt" 
```

With the `--manual` switch the prompt can be executed manually, which means that the rendered prompt is copied to the clipboard, for pasting and executing it with the LLM interface of your choice. By default, you're asked interactively to paste the result of this execution, from which a prompt result document is created.

```sh
$ mix magma.prompt.exec "Name of prompt" --manual
```

If the `--no-interactive` switch is used, there's no prompt to paste result back and an empty prompt result document is created instead (this is just used for the Obsidian buttons where such an shell interaction is not possible).

Ignore the `--trim_header`  option.

# Context knowledge



# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Mix.Tasks.Magma.Prompt.Exec]]
- Final version: [[ModuleDoc of Mix.Tasks.Magma.Prompt.Exec]]

### ModuleDoc prompt task

Generate documentation for module `Mix.Tasks.Magma.Prompt.Exec` according to its description and code in the knowledge base below.

![[Prompt snippets#Mix task moduledoc]]

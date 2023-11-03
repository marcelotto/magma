---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.DocumentStruct]]"
magma_draft: "[[Generated ModuleDoc of Magma.DocumentStruct (2023-10-18T14:57:32)]]"
created_at: 2023-10-18 16:49:16
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.DocumentStruct

## Moduledoc

Provides an abstract representation of a Markdown document structured based on the Pandoc AST.

The `Magma.DocumentStruct` module provides an Elixir struct for representing the contents of a Markdown document as an Abstract Syntax Tree (AST) based on the Pandoc AST. The struct is designed to access the individual sections including their subsections and facilitate the transclusion resolution feature, which is essential for the prompt generation in Magma.

The `Magma.DocumentStruct` struct consists of a prologue, which is the header-less text before the first section, and all sections of level 1 (which in turn consist of sections of level 2 and so on). The core functionalities related to sections are implemented in the `Magma.DocumentStruct.Section` module. The `Magma.DocumentStruct` acts as a wrapper around this recursive section structure and delegates most of its functions to the said module.


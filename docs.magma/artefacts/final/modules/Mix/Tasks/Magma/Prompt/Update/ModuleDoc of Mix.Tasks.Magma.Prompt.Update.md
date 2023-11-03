---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Update]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Prompt.Update (2023-11-02T16:40:58)]]"
created_at: 2023-11-02 16:42:15
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Prompt.Update

## Moduledoc

A Mix task for regenerating artefact prompt documents.

This task is useful for example when an artefact prompt contains the code of a module that has been modified since the creation of the prompt document. By regenerating the artefact prompt, the updated code is reflected in the prompt document.

```sh
$ mix magma.prompt.update "Name of a Prompt"
```

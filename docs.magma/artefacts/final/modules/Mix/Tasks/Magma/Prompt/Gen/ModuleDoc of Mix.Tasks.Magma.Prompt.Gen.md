---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Gen]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Prompt.Gen (2023-11-02T16:19:25)]]"
created_at: 2023-11-02 16:20:57
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Prompt.Gen

## Moduledoc

A Mix task for generating Magma artefact prompt documents and custom prompt documents.

This Mix task is used to create either a custom Magma prompt document or an artefact prompt document. The task requires different arguments depending on the type of document to be created. 

For a custom prompt document, a single argument representing the name of the prompt is required. 

```sh
$ mix magma.prompt.gen "Prompt for something"
```

For an artefact prompt document, two arguments are needed: the first being the name of a concept and the second being the artefact type. The artefact type should be the last part of an `Magma.Artefacts.X` artefact type module, e.g. `ModuleDoc` or `Readme`.

```sh
$ mix magma.prompt.gen "Some.Module" ModuleDoc
```

Note that, by default, all artefact prompts of a concept (according to its matter type) are already created when a concept document is created. Therefore, it's usually not necessary to use this task for generating artefact prompt documents. If you only want to update an existing artefact prompt, you can use the `Mix.Tasks.Magma.Prompt.Update` Mix task instead.

### Command line options

- `--force` - When set, this option allows the task to overwrite existing documents without asking for permission first.

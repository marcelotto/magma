---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.New]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Text.New (2023-11-02T20:16:47)]]"
created_at: 2023-11-02 20:18:28
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Text.New

## Moduledoc

A Mix task for generating the concept and artefact prompt documents for a new text.

The first argument is the title of your text, followed by an optional text type. The text type corresponds to the last part of the available text type modules of the form `Magma.Matter.Texts.X`. The text type determines the details of the system prompt of the artefact prompts. If no text type is given, a minimal generic system prompt is used which can be refined according to the user's needs.

``` sh
$ mix magma.text.new "Example User Guide" UserGuide
```

### Command line options

- `--force` - When set, this option allows the task to overwrite existing documents without asking for permission first.

---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.Assemble]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Text.Assemble (2023-11-02T21:01:22)]]"
created_at: 2023-11-02 21:02:29
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Text.Assemble

## Moduledoc

A Mix task for generating the section documents of a text from its final table of contents.

This task is used once the final artefact version document for the `Magma.Artefacts.TableOfContents` of a text has been created. This task will then create the concept and artefact prompt documents of the sections of the text and assemble the preview document.

```sh
mix magma.text.assemble "Name of ToC document"
```

### Command line options

- `--force` - Allows the task to overwrite existing documents without asking for permission first. 

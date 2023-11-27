---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Text.Type.New]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Text.Type.New (2023-11-25T22:42:59)]]"
created_at: 2023-11-25 22:47:06
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Text.Type.New

## Moduledoc

A Mix task for generating a new text type.

This task is used to create a configuration document for a new text type. Users must specify a valid Elixir module name as the text type name as the first argument. Optionally, a human-readable label can be provided.

### Example

To create a new text type with just the name:

```shell
$ mix magma.text.type.new MyTextType
```

To create a new text type with a name and a label:

```shell
$ mix magma.text.type.new MyTextType "My Custom Text Type"
```

### Command line options

- `--force` - Overwrites any existing text type configuration without confirmation (default: false)

---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Project]]"
magma_draft: "[[Generated ModuleDoc of Magma.Matter.Project (2023-10-19T20:25:11)]]"
created_at: 2023-10-19 20:32:56
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Matter.Project

## Moduledoc

This module provides an implementation of the `Magma.Matter` behaviour for the project that Magma is used for. It is unique in that there is only one instance of it, representing the single project for which artefacts are being created.

The `Magma.Matter.Project` module is primarily used to create and manage instances of a project matter, define the available artefacts for a project, and specify various properties and behaviours related to a project matter.

## Function docs

### `artefacts/0`

This function returns a list of `Magma.Artefact` types that are available for a project.

Example:

```elixir
iex> Magma.Matter.Project.artefacts()
[]
```

### `new/1`

This function creates a new instance of `Magma.Matter.Project` from the given name and returns it in an `:ok` tuple.

Example:

```elixir
iex> Magma.Matter.Project.new("my_project")
{:ok, %Magma.Matter.Project{name: "my_project"}}
```

### `new!/1`

This function creates a new instance of `Magma.Matter.Project` from the given name. Unlike `new/1`, this function will raise an error if it fails to create a new instance.

Example:

```elixir
iex> Magma.Matter.Project.new!("my_project")
%Magma.Matter.Project{name: "my_project"}
```

### `extract_from_metadata/3`

This function extracts the project name from the metadata of a document and creates a new `Magma.Matter.Project` instance with it. If the project name is not found in the metadata, it returns an error.

### `render_front_matter/1`

This function renders the front matter for a `Magma.Matter.Project` instance. It includes the output of the `Magma.Matter`'s `render_front_matter/1` function and adds the `magma_matter_name` field with the project's name.

### `default_concept_aliases/1`

This function returns the default concept aliases for a `Magma.Matter.Project` instance. The aliases are based on the project's name.

### `relative_base_path/1`, `relative_concept_path/1`, `concept_name/1`, `concept_title/1`

These functions return various properties of a `Magma.Matter.Project` instance, such as its base path, concept path, concept name, and concept title.

### `default_description/2`

This function returns the default description for a `Magma.Matter.Project` instance. The description is a question asking what the project (identified by its name) is about.

### `prompt_concept_description_title/1`

This function returns the title for the concept description prompt of a `Magma.Matter.Project` instance. The title includes the name of the project.

### `app_name/0`, `version/0`, `concept/0`, `modules/0`

These functions return various properties of the project, such as its application name, version, concept, and modules.

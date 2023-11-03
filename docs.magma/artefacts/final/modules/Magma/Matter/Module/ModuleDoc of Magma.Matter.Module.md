---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Module]]"
magma_draft: "[[Generated ModuleDoc of Magma.Matter.Module (2023-10-19T16:47:27)]]"
created_at: 2023-10-19 16:49:11
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Matter.Module

## Moduledoc

`Magma.Matter` type for the representation of Elixir modules.

The `Magma.Matter.Module` struct is used for generation of `Magma.Artefact`s about Elixir modules. It does not have any additional fields above the `Magma.Matter.fields/0` as it retrieves all necessary information via the Elixir and Erlang reflection API from the module name.

### Example

```elixir
iex> Magma.Matter.Module.new(name: "MyModule")
{:ok, %Magma.Matter.Module{name: MyModule}}
```

## Function docs

### `new/1`

Creates a new `Magma.Matter.Module` instance from a given module name. The module name can be provided as a binary string or as an atom. If the module name is provided as a binary string, it will be converted to an atom.

### `new!/1`

Similar to `new/1`, but raises an error if the creation of the `Magma.Matter.Module` instance fails.

### `relative_base_path/1`

Returns the base path for the module, which is used for different kinds of documents for this type of matter. The base path for modules is "modules".

### `relative_concept_path/1`

Generates the relative path for the concept document of the module. The path is constructed by joining the base path with the context segments of the module, and appending the concept name of the module.

### `concept_name/1`

Returns the name of the module as a string. The name is the atom of the module converted to a string.

### `concept_title/1`

Returns the title of the module, which is the name of the module enclosed in backticks.

### `default_description/1`

Generates a default description for the module. The description is a comment that prompts the user to provide information about the module.

### `context_knowledge/1`

Generates a section of context knowledge for the module. This includes information about peripherally relevant modules, which are the context modules and submodules of the module.

### `prompt_concept_description_title/1`

Returns the title for the concept description of the module in the artefact prompt.

### `prompt_matter_description/1`

Generates a description of the module for the artefact prompt. This includes a section titled "Module code" that contains the source code of the module.

### `source_path/1`

Returns the source path of the module, if it exists. The source path is the file path where the source code of the module is located.

### `code/1`

Returns the source code of the module, if it exists. The source code is read from the file at the source path of the module.

### `ignore?/1`

Determines whether the module should be ignored when generating documentation. A module is ignored if it has a "Magma pragma: ignore" comment at the beginning of its source code, or if it is marked as hidden and does not have a "Magma pragma: include" comment.

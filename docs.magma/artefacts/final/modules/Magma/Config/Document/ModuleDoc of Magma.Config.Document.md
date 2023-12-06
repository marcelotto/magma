---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Config.Document]]"
magma_draft: "[[Generated ModuleDoc of Magma.Config.Document (2023-12-06T21:12:16)]]"
created_at: 2023-12-06 21:14:36
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Magma.Config.Document

## Function docs

### `default_tags/0`

Returns the default tags for Magma configuration documents.

This function provides the list of default tags that should be applied to all
Magma configuration documents. These tags are used to categorize and identify
documents within the Magma environment.

#### Example

```elixir
Magma.Config.Document.default_tags()
# => ["magma-config"]
```

### `context_knowledge_section_title/0`

The title for the context knowledge section in configuration documents.

This function is used to consistently name the section that contains context
knowledge within Magma configuration documents. This ensures uniformity across
all documents that include a context knowledge section.

#### Example

```elixir
Magma.Config.Document.context_knowledge_section_title()
# => "Context knowledge"
```

### `init/1`

Initializes a new Magma configuration document with default tags.

This function is used to set up a new Magma configuration document, applying the
default set of tags to it. It is typically used when creating a new
configuration document to ensure that it is properly tagged.

#### Example

```elixir
document = %Magma.Document{content: "# Configuration"}
Magma.Config.Document.init(document)
# => %Magma.Document{content: "# Configuration", tags: ["magma-config"]}
```

## Moduledoc

Provides foundational behaviors for Magma configuration documents.

The `Magma.Config.Document` module is a base module that defines shared behavior
and attributes for Magma configuration documents. It is used to ensure
consistency and standardization of configuration documents across the Magma
project. It includes functionality to initialize documents with default tags and
to extract context knowledge sections.

Main functions include `default_tags/0` which returns the default tags for
configuration documents, `context_knowledge_section_title/0` which provides the
title for context knowledge sections, and `init/1` for initializing new
configuration documents with these defaults.

#### Example

To use `Magma.Config.Document` as a base for a new document type:

```elixir
defmodule MyApp.Config do
  use Magma.Config.Document, fields: [:my_custom_field]
end
```

In the example above, the `MyApp.Config` module will inherit the behaviors from
`Magma.Config.Document` and include an additional custom field `:my_custom_field`
in its structure.

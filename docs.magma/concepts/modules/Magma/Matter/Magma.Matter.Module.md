---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:13
tags: [magma-vault]
aliases: []
---
# `Magma.Matter.Module`

## Description

A `Magma.Matter` type for the representation of Elixir modules.

# Context knowledge


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Matter.Module]]
- Final version: [[ModuleDoc of Magma.Matter.Module]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Matter.Module` according to its description and code in the knowledge base below.

For the documentation of the functions implementing the `Magma.Matter` callbacks, use their documentation as a basis:

```elixir
defmodule Magma.Matter do  
  @moduledoc """  
  Behaviour for types of matter that can be subject of a `Magma.Concept` and the `Magma.Artefact`s generated from these concepts.  
  
  This module defines a set of callbacks that each matter type must implement.  
  These callbacks allow for the specification of various properties and  
  behaviours of the matter type, such as the available artefacts, paths for  
  different kinds of documents, texts for different parts of the concept and  
  prompt documents, and more.  
  """  
  
  @type t :: struct  
  
  @type name :: binary | atom  
  
  alias Magma.Concept  
  
  @fields [:name]  
  @doc """  
  Returns a list of the shared fields of the structs of every type of `Magma.Matter`.  
  
      iex> Magma.Matter.fields()  
  #{inspect(@fields)}  
  
  """  
  def fields, do: @fields  
  
  @doc """  
  A callback that returns the list of `Magma.Artefact` types that are available for this matter type.  
  """  
  @callback artefacts :: list(Magma.Artefact.t())  
  
  @doc """  
  A callback that returns the path segment to be used for different kinds of documents for this type of matter.  
  
  This path segment will be incorporated in the path generator functions  
  of the `Magma.Document` types.  
  """  
  @callback relative_base_path(t()) :: Path.t()  
  
  @doc """  
  A callback that returns the path for `Magma.Concept` documents about this type of matter.  
  
  This path is relative to the `Magma.Vault.concept_path/0`  
  """  
  @callback relative_concept_path(t()) :: Path.t()  
  
  @doc """  
  A callback that returns the name of the `Magma.Concept` document.  
  
  Note that this name must unique across all document names in the vault.  
  """  
  @callback concept_name(t()) :: binary  
  
  @doc """  
  A callback that returns the title header text of the `Magma.Concept` document.  
  """  
  @callback concept_title(t()) :: binary  
  
  @doc """  
  A callback that returns a text for the body of the "Description" section in the `Magma.Concept` document.  
  
  As the description is something written by the user, this should return  
  a comment with a hint of what is expected to be written.  
  """  
  @callback default_description(t(), keyword) :: binary  
  
  @doc """  
  A callback that can be used to define additional sections for the `Magma.Concept` document.  
  """  
  @callback custom_concept_sections(Concept.t()) :: binary | nil  
  
  @doc """  
  A callback that allows to specify texts which should be included generally in the "Context knowledge" section of the `Magma.Concept` document about this type of matter.  
  """  
  @callback context_knowledge(Concept.t()) :: binary | nil  
  
  @doc """  
  A callback that returns the section title for the concept description of a type of matter in the `Magma.Artefact.Prompt`.  
  """  
  @callback prompt_concept_description_title(t()) :: binary  
  
  @doc """  
  A callback that can be used to define a general description of some matter which should be included in the `Magma.Artefact.Prompt`.  
  
  This is used for example to include the code of module, in the case of `Magma.Matter.Module`.  
  """  
  @callback prompt_matter_description(t()) :: binary | nil  
  
  @doc """  
  A callback that returns a list of Obsidian aliases for the `Magma.Concept` document of this type of matter.  
  """  
  @callback default_concept_aliases(t()) :: list  
  
  @doc """  
  A callback that renders the matter-specific fields of this type of matter to YAML frontmatter.  
  
  Counterpart of `extract_from_metadata/3`.  
  """  
  @callback render_front_matter(t()) :: binary  
  
  @doc """  
  A callback that extracts an instance of this matter type from the matter-specific fields of the metadata during deserialization of a `Magma.Concept` document.  
  
  All YAML frontmatter properties are loaded first into the `:custom_metadata`  
  map of a `Magma.Document`. This callback implementation should `Map.pop/2` the  
  matter-specific entries from the given `document_metadata` and return the created  
  instance of this matter type and the consumed metadata in an ok tuple.  
  
  Counterpart of `render_front_matter/1`.  
  """  
  @callback extract_from_metadata(  
              document_name :: binary,  
              document_title :: binary,  
              document_metadata :: map  
            ) :: {:ok, t(), keyword} | {:error, any}
end
```
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

  @type type :: module

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

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      alias Magma.View

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def custom_concept_sections(%Concept{}), do: nil

      @impl true
      def context_knowledge(%Concept{}), do: nil

      @impl true
      def prompt_matter_description(%__MODULE__{}), do: nil

      @impl true
      def render_front_matter(%__MODULE__{}) do
        "magma_matter_type: #{Magma.Matter.type_name(__MODULE__)}"
      end

      @impl true
      def extract_from_metadata(document_name, _document_title, metadata) do
        with {:ok, matter} <- new(name: document_name) do
          {:ok, matter, metadata}
        end
      end

      defoverridable default_concept_aliases: 1,
                     custom_concept_sections: 1,
                     context_knowledge: 1,
                     prompt_matter_description: 1,
                     render_front_matter: 1,
                     extract_from_metadata: 3
    end
  end

  @doc """
  Extracts an instance of a matter from the matter-specific fields of the metadata of a `Magma.Concept` document.

  This function first extracts the matter type from the `magma_matter_type` field
  in the YAML frontmatter and then delegates to the `c:extract_from_metadata/3`
  implementation to process the matter-type specific fields.
  """
  def extract_from_metadata(document_name, document_title, metadata) do
    with {:ok, matter_type, remaining_metadata} <- extract_type(metadata) do
      matter_type.extract_from_metadata(document_name, document_title, remaining_metadata)
    end
  end

  defp extract_type(metadata) do
    {matter_type, remaining} = Map.pop(metadata, :magma_matter_type)

    cond do
      !matter_type -> {:error, "magma_matter_type missing"}
      matter_module = type(matter_type) -> {:ok, matter_module, remaining}
      true -> {:error, "invalid magma_matter type: #{matter_type}"}
    end
  end

  @doc """
  Returns the matter type name for the given matter type module.

  ## Example

      iex> Magma.Matter.type_name(Magma.Matter.Module)
      "Module"

      iex> Magma.Matter.type_name(Magma.Matter.Text)
      "Text"

      iex> Magma.Matter.type_name(Magma.Matter.Text.Section)
      "Text.Section"

      iex> Magma.Matter.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Matter type: Magma.Vault

      iex> Magma.Matter.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Matter type: NonExisting

  """
  @spec type(type()) :: binary
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Matter" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Matter type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Matter type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the matter type module for the given string.

  ## Example

      iex> Magma.Matter.type("Module")
      Magma.Matter.Module

      iex> Magma.Matter.type("Project")
      Magma.Matter.Project

      iex> Magma.Matter.type("Vault")
      nil

      iex> Magma.Matter.type("NonExisting")
      nil

  """
  @spec type(binary) :: type() | nil
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if type?(module) do
      module
    end
  end

  @doc """
  Checks if the given `module` is a `Magma.Matter` type module.
  """
  @spec type?(module) :: boolean
  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_concept_path, 1)
  end
end

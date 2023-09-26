defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  alias Magma.Concept

  @fields [:name]
  def fields, do: @fields

  @callback artefacts :: list(Magma.Artefact.t())

  @callback relative_base_path(t()) :: Path.t()

  @callback relative_concept_path(t()) :: Path.t()

  @callback concept_name(t()) :: binary

  @callback concept_title(t()) :: binary

  @callback default_description(t(), keyword) :: binary

  @callback custom_sections(Concept.t()) :: binary

  @callback prompt_representation(t()) :: binary | nil

  @callback default_concept_aliases(t()) :: list

  @callback new(keyword) :: {:ok, t(), keyword} | {:error, any}

  @callback extract_from_metadata(
              document_name :: binary,
              document_title :: binary,
              document_metadata :: keyword
            ) :: {:ok, t(), keyword} | {:error, any}

  @callback render_front_matter(t()) :: binary

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      alias Magma.Obsidian.View

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def custom_sections(%Concept{}), do: ""

      @impl true
      def prompt_representation(%__MODULE__{}), do: nil

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
                     custom_sections: 1,
                     prompt_representation: 1,
                     render_front_matter: 1,
                     extract_from_metadata: 3
    end
  end

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
  Returns the matter type name for the given matter module.

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
  Returns the matter module for the given string.

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
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_concept_path, 1)
  end
end

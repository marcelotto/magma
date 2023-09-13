defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  @fields [:name]
  def fields, do: @fields

  @callback concept_path(t()) :: Path.t()

  @callback default_concept_aliases(t()) :: list

  @callback new(keyword) :: {:ok, t(), keyword} | {:error, any}

  @callback extract_from_metadata(
              document_name :: binary,
              document_title :: binary,
              document_metadata :: keyword
            ) :: {:ok, t(), keyword} | {:error, any}

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def extract_from_metadata(document_name, _document_title, metadata) do
        with {:ok, matter} <- new(name: document_name) do
          {:ok, matter, metadata}
        end
      end

      defoverridable default_concept_aliases: 1, extract_from_metadata: 3
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

    if Code.ensure_loaded?(module) and function_exported?(module, :concept_path, 1) do
      module
    end
  end
end

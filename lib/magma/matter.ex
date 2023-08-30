defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  @fields [:name]
  def fields, do: @fields

  @callback concept_path(t()) :: Path.t()

  @callback default_concept_aliases(t()) :: list

  @callback new(name, keyword) :: {:ok, t()} | {:error, any}

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def default_concept_aliases(%__MODULE__{}), do: []

      @impl true
      def new(name, args \\ []) do
        %__MODULE__{
          name: name
        }
        |> struct(args)
      end

      defoverridable new: 1, new: 2, default_concept_aliases: 1
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

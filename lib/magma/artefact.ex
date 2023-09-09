defmodule Magma.Artefact do
  alias Magma.Concept

  @fields [:name, :concept]
  def fields, do: @fields

  @type t :: struct

  @callback matter_type :: module

  @callback build_name(Concept.t()) :: binary

  @callback build_prompt_path(t()) :: Path.t()

  @callback build_version_path(t()) :: Path.t()

  @callback init(t()) :: {:ok, t()} | {:error, any}

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      defstruct Artefact.fields() ++ unquote(additional_fields)

      @impl true
      def matter_type, do: unquote(matter_type)

      def new(%Magma.Concept{subject: %unquote(matter_type){}} = concept, args \\ []) do
        %__MODULE__{
          concept: concept,
          name: build_name(concept)
        }
        |> struct(args)
        |> init()
      end

      def new!(concept, args \\ []) do
        case new(concept, args) do
          {:ok, artefact} -> artefact
          {:error, error} -> raise error
        end
      end
    end
  end

  @doc """
  Returns the artefact module for the given string.

  ## Example

      iex> Magma.Artefact.type("ModuleDoc")
      Magma.Artefacts.ModuleDoc

      iex> Magma.Artefact.type("Vault")
      nil

      iex> Magma.Artefact.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Artefacts, string)

    if Code.ensure_loaded?(module) and function_exported?(module, :build_prompt_path, 1) do
      module
    end
  end
end

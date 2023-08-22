defmodule Magma.Artefact do
  alias Magma.Concept

  @fields [:name, :concept]
  def fields, do: @fields

  @type t :: struct

  @callback matter_type :: module

  @callback name(Concept.t()) :: binary

  @callback prompt_path(t()) :: Path.t()

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
          name: name(concept)
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
end

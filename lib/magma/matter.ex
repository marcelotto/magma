defmodule Magma.Matter do
  @type t :: struct

  @type name :: binary | atom

  @fields [:name]
  def fields, do: @fields

  @callback concept_path(t()) :: Path.t()

  @callback new(name, keyword) :: {:ok, t()} | {:error, any}

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Matter

      defstruct Magma.Matter.fields() ++ unquote(additional_fields)

      @impl true
      def new(name, args \\ []) do
        %__MODULE__{
          name: name
        }
        |> struct(args)
      end

      defoverridable new: 1, new: 2
    end
  end
end

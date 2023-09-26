defmodule Magma.Matter.Text.Type do
  @callback system_prompt(Concept.t()) :: binary

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      def new(name) do
        Magma.Matter.Text.new!(__MODULE__, name)
      end
    end
  end
end

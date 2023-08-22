defmodule Magma.Document.Template do
  @type assigns :: list

  @callback render(Magma.Document.t(), assigns) :: binary

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      import Magma.Obsidian.View.Helper
    end
  end
end

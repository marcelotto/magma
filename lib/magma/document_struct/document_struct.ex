defmodule Magma.DocumentStruct do
  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}

  def new(args) do
    struct(__MODULE__, args)
  end

  defdelegate parse(content), to: Parser

  defdelegate fetch(document_struct, key), to: Section
end
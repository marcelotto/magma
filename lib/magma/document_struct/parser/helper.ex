defmodule Magma.DocumentStruct.Parser.Helper do
  @moduledoc false

  alias Panpipe.AST.Header

  def header_title(%Header{children: [child]}) do
    Panpipe.to_markdown(child)
  end

  def header_title(%Header{children: children}) do
    %Panpipe.AST.Para{children: children}
    |> Panpipe.to_markdown()
    |> String.trim()
  end
end

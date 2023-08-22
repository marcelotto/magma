defmodule Magma.DocumentStruct.Section do
  defstruct [:title, :header, :level, :content, :sections]

  alias Panpipe.AST.Header

  import Magma.DocumentStruct.Parser.Helper

  def new(%Header{level: level} = header, content, sections) do
    %__MODULE__{
      title: header_title(header),
      header: header,
      level: level,
      content: content,
      sections: sections
    }
  end

  def fetch(%_{sections: sections}, key) do
    Enum.find_value(sections, fn
      {^key, section} -> {:ok, section}
      _ -> nil
    end) || :error
  end
end

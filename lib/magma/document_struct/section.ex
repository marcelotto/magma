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

  def to_string(%__MODULE__{} = section, opts \\ []) do
    children =
      if Keyword.get(opts, :header, false) do
        [section.header | section.content]
      else
        section.content
      end

    result =
      %Panpipe.Document{children: children}
      |> Panpipe.to_markdown()

    if Keyword.get(opts, :subsections, true) && not Enum.empty?(section.sections) do
      result <>
        "\n" <>
        Enum.map_join(section.sections, "\n", fn {_, subsection} ->
          to_string(subsection, header: true)
        end)
    else
      result
    end
  end
end

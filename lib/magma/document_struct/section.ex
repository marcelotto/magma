defmodule Magma.DocumentStruct.Section do
  defstruct [:title, :header, :level, :content, :sections]

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.TransclusionResolution
  alias Panpipe.AST.Header

  @default_link_resolution_style :plain

  def new(%Header{} = header, content, sections) do
    %__MODULE__{
      content: content,
      sections: sections
    }
    |> set_header(header)
  end

  def set_header(%__MODULE__{} = section, %Header{} = header) do
    %__MODULE__{
      section
      | header: header,
        title: header_title(header),
        level: header.level
    }
  end

  defp header_title(%Header{children: children}) do
    %Panpipe.Document{children: [%Panpipe.AST.Para{children: children}]}
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension())
    |> String.trim()
  end

  def fetch(%_{sections: sections}, title) do
    Enum.find_value(sections, fn
      %{title: ^title} = section -> {:ok, section}
      _ -> nil
    end) || :error
  end

  def empty?(%__MODULE__{content: [], sections: []}), do: true
  def empty?(%__MODULE__{}), do: false

  def empty_content?(%__MODULE__{} = section) do
    section.content == [] && Enum.all?(section.sections, &empty_content?/1)
  end

  def section_by_title(%__MODULE__{title: title} = section, title), do: section

  def section_by_title(%__MODULE__{} = section, title) do
    Enum.find_value(section.sections, &section_by_title(&1, title))
  end

  @doc false
  def ast(%__MODULE__{} = section, opts \\ []) do
    {with_header, opts} = Keyword.pop(opts, :header, true)

    {section, opts} =
      case Keyword.pop(opts, :remove_comments, false) do
        {true, opts} -> {remove_comments(section), opts}
        {_, opts} -> {section, opts}
      end

    section
    |> set_level(Keyword.get(opts, :level))
    |> do_ast(with_header, opts)
  end

  defp do_ast(section, with_header \\ true, opts \\ []) do
    if with_header do
      [section.header | section.content]
    else
      section.content
    end ++
      if Keyword.get(opts, :subsections, true) do
        Enum.flat_map(section.sections, &do_ast/1)
      else
        []
      end
  end

  def to_markdown(%__MODULE__{} = section, opts \\ []) do
    %Panpipe.Document{children: ast(section, opts)}
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension(), wrap: "none")
  end

  def set_level(%__MODULE__{} = section, nil), do: section

  def set_level(%__MODULE__{}, new_level) when new_level < 0,
    do: raise("invalid header level: #{new_level}")

  def set_level(%__MODULE__{level: level} = section, new_level),
    do: shift_level(section, new_level - level)

  def shift_level(%__MODULE__{level: level}, shift_level) when level + shift_level < 0 do
    raise "shifting to negative header level"
  end

  def shift_level(%__MODULE__{} = section, 0), do: section

  def shift_level(%__MODULE__{} = section, shift_level) do
    %__MODULE__{
      section
      | level: section.level + shift_level,
        header: %Panpipe.AST.Header{section.header | level: section.header.level + shift_level},
        sections: Enum.map(section.sections, &shift_level(&1, shift_level))
    }
  end

  defdelegate resolve_transclusions(section), to: TransclusionResolution

  def resolve_links(%__MODULE__{} = section, opts \\ []) do
    do_resolve_links(
      section,
      opts
      |> Keyword.get(:style)
      |> link_resolution_style()
    )
  end

  defp do_resolve_links(section, style) do
    %__MODULE__{
      section
      | content: Enum.map(section.content, &transform_links(&1, style)),
        sections: Enum.map(section.sections, &do_resolve_links(&1, style))
    }
  end

  defp transform_links(ast, style) do
    Panpipe.transform(ast, fn
      %Panpipe.AST.Link{title: "wikilink", children: children} -> style.(children)
      _ -> nil
    end)
  end

  defp link_resolution_style(nil), do: default_link_resolution_style() |> link_resolution_style()
  defp link_resolution_style(:plain), do: & &1
  defp link_resolution_style(:emph), do: &%Panpipe.AST.Emph{children: &1}
  defp link_resolution_style(:strong), do: &%Panpipe.AST.Strong{children: &1}
  defp link_resolution_style(:underline), do: &%Panpipe.AST.Underline{children: &1}
  defp link_resolution_style(fun) when is_function(fun), do: fun

  defp default_link_resolution_style do
    Application.get_env(:magma, :link_resolution_style, @default_link_resolution_style)
  end

  def remove_comments(%__MODULE__{} = section) do
    %__MODULE__{
      section
      | content: remove_comments(section.content),
        sections: Enum.map(section.sections, &remove_comments/1)
    }
  end

  def remove_comments(content) when is_list(content) do
    Enum.flat_map(content, &List.wrap(do_remove_comments(&1)))
  end

  def do_remove_comments(%Panpipe.AST.RawBlock{format: "html", string: "<!--" <> comment} = ast) do
    unless String.ends_with?(comment, "-->") do
      ast
    end
  end

  def do_remove_comments(ast) do
    Panpipe.transform(ast, fn
      %Panpipe.AST.RawInline{format: "html", string: "<!--" <> comment} ->
        if String.ends_with?(comment, "-->"), do: []

      _ ->
        nil
    end)
  end
end

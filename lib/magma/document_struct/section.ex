defmodule Magma.DocumentStruct.Section do
  @moduledoc """
  Recursive structure for the nested sections of a `Magma.DocumentStruct`.
  """

  defstruct [:title, :level, :header, :content, :sections]

  @type t :: %__MODULE__{
          title: binary,
          level: integer,
          header: Panpipe.AST.Header.t(),
          content: [Panpipe.AST.Node.t()],
          sections: [t()]
        }

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.TransclusionResolution
  alias Panpipe.AST.Header

  @doc """
  Creates a new section.
  """
  @spec new(Header.t() | {pos_integer(), binary}, [Panpipe.AST.Node.t()], [t()]) :: t()
  def new(header, content, sections \\ [])

  def new(%Header{} = header, content, sections) do
    content
    |> do_new(sections)
    |> set_header(header)
  end

  def new({level, title}, content, sections) do
    content
    |> do_new(sections)
    |> set_header(title, level)
  end

  defp do_new(content, sections) do
    %__MODULE__{
      content: content,
      sections: sections
    }
  end

  @doc """
  Sets a new `header` for the given `section`, updating the `:title` and `:level` fields accordingly.
  """
  def set_header(%__MODULE__{} = section, %Header{} = header) do
    %__MODULE__{
      section
      | header: header,
        title: header_title(header),
        level: header.level
    }
  end

  @doc """
  Sets a new header with the given title and level for the given `section`, updating the `:title` and `:level` fields accordingly.
  """
  def set_header(%__MODULE__{} = section, title, level)
      when is_binary(title) and is_integer(level) do
    %__MODULE__{
      section
      | header: to_pandoc_header(title, level),
        title: title,
        level: level
    }
  end

  defp to_pandoc_header(title, level) do
    %Panpipe.Document{children: [header]} =
      Panpipe.ast!("#{String.duplicate("#", level)} #{title}")

    header
  end

  defp header_title(%Header{children: children}) do
    %Panpipe.Document{children: [%Panpipe.AST.Para{children: children}]}
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension())
    |> String.trim()
  end

  @doc """
  Fetches the section with the given `title` and returns it in an ok tuple.

  If no section with `section` exists, it returns `:error`.

  This implements `Access.fetch/2` function, so that the `section[title]`
  syntax and the `Kernel` macros for accessing nested data structures like
  `get_in/2` are supported.

  This function only searches sections directly under the given section.
  For a recursive search, use `section_by_title/2`.
  """
  @spec fetch(t() | DocumentStruct.compatible(), binary) :: {:ok, t()} | :error
  def fetch(%_{sections: sections}, title) do
    Enum.find_value(sections, fn
      %{title: ^title} = section -> {:ok, section}
      _ -> nil
    end) || :error
  end

  @doc """
  Checks if the given `section` is empty, i.e. it has no `content` and nested `sections`.
  """
  @spec empty?(t()) :: boolean
  def empty?(%__MODULE__{content: [], sections: []}), do: true
  def empty?(%__MODULE__{}), do: false

  @doc """
  Checks if the given `section` consists solely of subsection headers.
  """
  @spec empty_content?(t()) :: boolean
  def empty_content?(%__MODULE__{} = section) do
    section.content == [] && Enum.all?(section.sections, &empty_content?/1)
  end

  @doc """
  Fetches the first section with the given `title`.

  Other than accessing the sections with the `fetch/2`, this searches the
  sections recursively.
  """
  @spec section_by_title(t(), binary) :: t() | nil
  def section_by_title(section, title)

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

  @doc """
  Converts a `Magma.DocumentStruct.Section` into a Markdown string.
  """
  @spec to_markdown(t(), keyword) :: binary
  def to_markdown(%__MODULE__{} = section, opts \\ []) do
    %Panpipe.Document{children: ast(section, opts)}
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension(), wrap: "none")
  end

  @doc """
  Changes the header level of `section` to the given `level`.

  Computes the difference to the current level of `section` and shifts the
  level recursively on all subsections using `shift_level/2`.
  """
  @spec set_level(t(), non_neg_integer()) :: t()
  def set_level(section, level)

  def set_level(%__MODULE__{} = section, nil), do: section

  def set_level(%__MODULE__{}, new_level) when new_level < 0,
    do: raise("invalid header level: #{new_level}")

  def set_level(%__MODULE__{level: level} = section, new_level),
    do: shift_level(section, new_level - level)

  @doc """
  Shifts the header level of `section` by the given `shift_level`.

  All subsections are shifted recursively.
  """
  @spec shift_level(t(), integer()) :: t()
  def shift_level(section, shift_level)

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

  @doc """
  Processes and resolves transclusions within the given `section`.

  Transclusion resolution in Magma is a procedure where an Obsidian transclusion,
  such as `![[Some document]]`, is replaced with its actual content.
  This mechanism forms the foundation for constructing LLM prompts in Magma.
  The content from the referenced document or section undergoes several processing
  steps before its insertion:

  - Comments (`<!-- comment -->`) are removed.
  - Internal links are replaced with the target as plain text.
  - Transclusions within the transcluded content itself are resolved recursively
    (unless it would result in an infinite recursion).
  - If the transcluded content (after removing the comments), consists
    exclusively of a heading with no content below it, the transclusion is
    resolved with the empty string.
  - The level of the transcluded sections is adjusted according to the current
    level at the point of the transclusion.

  Different types of transclusions are resolved in slightly varied ways,
  particularly regarding the leading header of the transcluded content:

  - _Inline transclusions_: Exclude the leading header.
  - _Custom header transclusions_: Replace the leading header.
  - _Empty header transclusions_: Retain the leading header.
  """

  defdelegate resolve_transclusions(section), to: TransclusionResolution

  @doc """
  Resolves internal links in the provided `section` by replacing them with their content or display text.

  The style of the resolved links can be specified with the `:style` option,
  which accepts the following values:

  - `:plain` (default) - no styling
  - `:emph` - italic
  - `:strong` - bold
  - `:underline` - underlined
  - a function accepting the children of the link AST and returning the
    replacement AST node
  """
  @spec resolve_links(t(), keyword) :: t()
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
    Magma.Config.system(:link_resolution_style)
  end

  @doc """
  Removes all comment blocks from the given `section_or_content`.

  This function cleans up the document by removing all comment blocks
  (`<!-- comment -->`).
  """
  def remove_comments(section_or_content)

  @spec remove_comments(t()) :: t()
  def remove_comments(%__MODULE__{} = section) do
    %__MODULE__{
      section
      | content: remove_comments(section.content),
        sections: Enum.map(section.sections, &remove_comments/1)
    }
  end

  @spec remove_comments([Panpipe.AST.Node.t()]) :: [Panpipe.AST.Node.t()]
  def remove_comments(content) when is_list(content) do
    Enum.flat_map(content, &List.wrap(do_remove_comments(&1)))
  end

  defp do_remove_comments(%Panpipe.AST.RawBlock{format: "html", string: "<!--" <> comment} = ast) do
    unless String.ends_with?(comment, "-->") do
      ast
    end
  end

  defp do_remove_comments(ast) do
    Panpipe.transform(ast, fn
      %Panpipe.AST.RawInline{format: "html", string: "<!--" <> comment} ->
        if String.ends_with?(comment, "-->"), do: []

      _ ->
        nil
    end)
  end

  def preserve_eex_tags(%__MODULE__{} = section) do
    %__MODULE__{
      section
      | content:
          Enum.map(
            section.content,
            &Panpipe.transform(&1, fn
              %Panpipe.AST.Str{string: "%>" <> _ = string} = node ->
                case String.split(string, ">") do
                  [left, right] ->
                    [
                      %Panpipe.AST.Str{string: left},
                      %Panpipe.AST.RawInline{string: ">", format: "markdown"},
                      %Panpipe.AST.Str{string: right}
                    ]

                  _ ->
                    node
                end

              %Panpipe.AST.Str{string: string} = node ->
                case String.split(string, "<") do
                  [left, right] ->
                    [
                      %Panpipe.AST.Str{string: left},
                      %Panpipe.AST.RawInline{string: "<", format: "markdown"},
                      %Panpipe.AST.Str{string: right}
                    ]

                  _ ->
                    node
                end

              _ ->
                nil
            end)
          )
    }
  end
end

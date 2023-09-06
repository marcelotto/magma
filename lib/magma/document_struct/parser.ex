defmodule Magma.DocumentStruct.Parser do
  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section
  alias Panpipe.AST.Header

  def parse(content) when is_binary(content) do
    with {:ok, document} <-
           content
           |> String.trim()
           |> Panpipe.ast(from: DocumentStruct.pandoc_extension()) do
      to_section(document)
    end
  end

  def to_section(%Panpipe.Document{children: children}), do: to_section(children)

  def to_section(ast_elements) when is_list(ast_elements) do
    {prologue, remaining} = extract_prologue(ast_elements)

    {:ok,
     DocumentStruct.new(
       prologue: prologue,
       sections: section_tree(remaining)
     )}
  end

  defp extract_prologue(children) do
    take_until_next_header(children)
  end

  defp section_tree([]), do: []

  defp section_tree([%Header{level: level} = header | rest]) do
    {content, remaining} = take_until_next_header(rest)
    {sub_sections, remaining} = take_until_next_outer_section(remaining, level)
    [Section.new(header, content, section_tree(sub_sections)) | section_tree(remaining)]
  end

  defp take_until_next_header(list, acc \\ [])

  defp take_until_next_header([], acc),
    do: {Enum.reverse(acc), []}

  defp take_until_next_header([%Header{} | _] = elements, acc),
    do: {Enum.reverse(acc), elements}

  defp take_until_next_header([element | rest], acc),
    do: take_until_next_header(rest, [element | acc])

  defp take_until_next_outer_section(list, outer_level, acc \\ [])

  defp take_until_next_outer_section([], _outer_level, acc),
    do: {Enum.reverse(acc), []}

  defp take_until_next_outer_section([%Header{level: level} | _] = remaining, outer_level, acc)
       when level <= outer_level do
    {Enum.reverse(acc), remaining}
  end

  defp take_until_next_outer_section([content | remaining], outer_level, acc) do
    take_until_next_outer_section(remaining, outer_level, [content | acc])
  end
end

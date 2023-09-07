defmodule Magma.DocumentStruct.Section do
  defstruct [:title, :header, :level, :content, :sections]

  alias Magma.DocumentStruct
  alias Magma.Document
  alias Panpipe.AST.Header

  require Logger

  def new(%Header{level: level} = header, content, sections) do
    %__MODULE__{
      title: header_title(header),
      header: header,
      level: level,
      content: content,
      sections: sections
    }
  end

  def fetch(%_{sections: sections}, title) do
    Enum.find_value(sections, fn
      %{title: ^title} = section -> {:ok, section}
      _ -> nil
    end) || :error
  end

  def section_by_title(%__MODULE__{title: title} = section, title), do: section

  def section_by_title(%__MODULE__{} = section, title) do
    Enum.find_value(section.sections, &section_by_title(&1, title))
  end

  @doc false
  def ast(%__MODULE__{} = section, opts \\ []) do
    {with_header, opts} = Keyword.pop(opts, :header, true)
    {resolve_transclusions, opts} = Keyword.pop(opts, :resolve_transclusions, false)

    if resolve_transclusions do
      resolve_transclusions(section)
    else
      section
    end
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

  def to_string(%__MODULE__{} = section, opts \\ []) do
    %Panpipe.Document{children: ast(section, opts)}
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension())
  end

  def set_level(%__MODULE__{} = section, nil), do: section

  def set_level(%__MODULE__{level: level}, new_level) when new_level < 1,
    do: raise("invalid header level: #{level}")

  def set_level(%__MODULE__{level: level} = section, new_level),
    do: shift_level(section, new_level - level)

  def shift_level(%__MODULE__{level: level}, shift_level) when level + shift_level < 1 do
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

  def resolve_transclusions(%__MODULE__{} = section) do
    {result, _} = do_resolve_transclusions(section, MapSet.new())
    result
  end

  defp do_resolve_transclusions(section, visited) do
    {resolved_content, new_sections, visited} =
      resolve_content_transclusions(section.content, section.level, visited)

    {resolved_subsections, visited} =
      Enum.reduce(section.sections, {[], visited}, fn
        subsection, {resolved_subsections, visited} ->
          {resolved_subsection, visited} = do_resolve_transclusions(subsection, visited)
          {[resolved_subsection | resolved_subsections], visited}
      end)

    resolved_sections = new_sections ++ Enum.reverse(resolved_subsections)

    case resolve_transclusion_header(section, visited) do
      {resolved_section, visited} ->
        {
          resolved_section
          |> append(resolved_content)
          |> Map.update!(:sections, &(&1 ++ resolved_sections)),
          visited
        }

      nil ->
        {
          %__MODULE__{
            section
            | content: resolved_content,
              sections: resolved_sections
          },
          visited
        }
    end
  end

  defp resolve_content_transclusions(content, level, visited) do
    {new_content, new_sections, visited} =
      Enum.reduce(content, {[], [], visited}, fn
        %Panpipe.AST.Figure{
          children: [
            %Panpipe.AST.Plain{
              children: [
                %Panpipe.AST.Image{title: "wikilink", target: target}
              ]
            }
          ]
        } = transclusion,
        {new_content, new_sections, visited} = acc ->
          if extract_document_name(target) in visited do
            raise "recursive cycle during transclusion resolution of #{target}"
          end

          case transcluded_content(target, level + 1, visited) do
            {resolved_transclusion, visited} ->
              {new_content, [resolved_transclusion | new_sections], visited}

            nil ->
              acc_append(transclusion, acc)
          end

        content, acc ->
          acc_append(content, acc)
      end)

    {Enum.reverse(new_content), Enum.reverse(new_sections), visited}
  end

  defp acc_append(content, {new_content, [], visited}),
    do: {[content | new_content], [], visited}

  defp acc_append(content, {new_content, [current | rest], visited}),
    do: {new_content, [append(current, content) | rest], visited}

  defp append(%__MODULE__{sections: []} = section, ast) do
    %__MODULE__{section | content: section.content ++ List.wrap(ast)}
  end

  defp append(%__MODULE__{} = section, ast) do
    %__MODULE__{section | sections: List.update_at(section.sections, -1, &append(&1, ast))}
  end

  defp resolve_transclusion_header(%__MODULE__{header: header} = section, visited) do
    case Enum.reverse(header.children) do
      [%Panpipe.AST.Image{title: "wikilink", target: target} | rest] ->
        if extract_document_name(target) in visited do
          raise "recursive cycle during transclusion resolution of #{target}"
        end

        if {resolved_transclusion, visited} = transcluded_content(target, section.level, visited) do
          new_header = %Panpipe.AST.Header{
            header
            | children: rest |> trim_leading_ast() |> Enum.reverse(),
              attr: nil
          }

          {
            %__MODULE__{
              resolved_transclusion
              | header: new_header,
                title: header_title(new_header)
            },
            visited
          }
        end

      _ ->
        nil
    end
  end

  defp transcluded_content(target, level, visited) do
    target
    |> parse_document_name()
    |> do_transcluded_content()
    |> case do
      nil ->
        nil

      {section, visited_document} ->
        {section, visited} =
          do_resolve_transclusions(section, MapSet.put(visited, visited_document))

        {set_level(section, level), visited}
    end
  end

  defp do_transcluded_content({document_name, section_title}) do
    with {:ok, document} <- Document.load(document_name) do
      cond do
        !section_title ->
          {DocumentStruct.main_section(document), document_name}

        section = DocumentStruct.section_by_title(document, section_title) ->
          {section, document_name}

        true ->
          Logger.warning("No section #{section_title} in #{document_name} found")
          nil
      end
    else
      {:error, error} ->
        Logger.warning("failed to load [[#{document_name}]] during resolution: #{inspect(error)}")
        nil
    end
  end

  defp parse_document_name(name) do
    case String.split(name, "#") do
      [document_name] -> {document_name, nil}
      [document_name, section] -> {document_name, section}
    end
  end

  def extract_document_name(name), do: name |> parse_document_name() |> elem(0)

  defp header_title(%Header{children: [child]}) do
    Panpipe.to_markdown(child)
  end

  defp header_title(%Header{children: children}) do
    %Panpipe.AST.Para{children: children}
    |> Panpipe.to_markdown()
    |> String.trim()
  end

  defp trim_leading_ast([%Panpipe.AST.Space{} | rest]), do: trim_leading_ast(rest)
  defp trim_leading_ast(ast), do: ast
end

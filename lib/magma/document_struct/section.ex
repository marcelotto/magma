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
    {resolved_content, resolved_sections} =
      do_resolve_transclusions(section.content, section.level)

    resolved_sections = resolved_sections ++ Enum.map(section.sections, &resolve_transclusions/1)

    if resolved_section = resolve_transclusion_header(section) do
      resolved_section
      |> append(resolved_content)
      |> Map.update!(:sections, &(&1 ++ resolved_sections))
    else
      %__MODULE__{
        section
        | content: resolved_content,
          sections: resolved_sections
      }
    end
  end

  defp do_resolve_transclusions(content, level) do
    {new_content, new_sections} =
      Enum.reduce(content, {[], []}, fn
        %Panpipe.AST.Figure{
          children: [
            %Panpipe.AST.Plain{
              children: [
                %Panpipe.AST.Image{title: "wikilink", target: target}
              ]
            }
          ]
        } = transclusion,
        {new_content, new_sections} = acc ->
          if resolved_transclusion = transcluded_content(target, level + 1) do
            {new_content, [resolved_transclusion | new_sections]}
          else
            acc_append(transclusion, acc)
          end

        content, acc ->
          acc_append(content, acc)
      end)

    {Enum.reverse(new_content), Enum.reverse(new_sections)}
  end

  defp acc_append(content, {new_content, []}), do: {[content | new_content], []}

  defp acc_append(content, {new_content, [current | rest]}),
    do: {new_content, [append(current, content) | rest]}

  defp append(%__MODULE__{sections: []} = section, ast) do
    %__MODULE__{section | content: section.content ++ List.wrap(ast)}
  end

  defp append(%__MODULE__{} = section, ast) do
    %__MODULE__{section | sections: List.update_at(section.sections, -1, &append(&1, ast))}
  end

  defp resolve_transclusion_header(%__MODULE__{header: header} = section) do
    case Enum.reverse(header.children) do
      [%Panpipe.AST.Image{title: "wikilink", target: target} | rest] ->
        if resolved_transclusion = transcluded_content(target, section.level) do
          new_header = %Panpipe.AST.Header{
            header
            | children: rest |> trim_leading_ast() |> Enum.reverse(),
              attr: nil
          }

          %__MODULE__{resolved_transclusion | header: new_header, title: header_title(new_header)}
        end

      _ ->
        nil
    end
  end

  defp transcluded_content(target, level) do
    case String.split(target, "#") do
      [document_name] -> do_transcluded_content(document_name, nil, level)
      [document_name, section] -> do_transcluded_content(document_name, section, level)
    end
  end

  defp do_transcluded_content(document_name, section_title, level) do
    with {:ok, document} <- Document.load(document_name) do
      cond do
        !section_title ->
          document
          |> DocumentStruct.main_section()
          |> resolve_transclusions()
          |> set_level(level)

        section = DocumentStruct.section_by_title(document, section_title) ->
          section
          |> resolve_transclusions()
          |> set_level(level)

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

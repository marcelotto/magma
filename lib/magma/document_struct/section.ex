defmodule Magma.DocumentStruct.Section do
  defstruct [:title, :header, :level, :content, :sections]

  alias Magma.{DocumentStruct, Document, Concept, Vault}
  alias Magma.TopLevelEmptyHeaderTransclusionError
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

  def to_string(%__MODULE__{} = section, opts \\ []) do
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

  def resolve_transclusions(%__MODULE__{} = section) do
    case do_resolve_transclusions(section, []) do
      {:transclusion_expansion, _, _} -> raise TopLevelEmptyHeaderTransclusionError
      %__MODULE__{} = resolved -> resolved
    end
  end

  defp do_resolve_transclusions(section, visited) do
    {resolved_content, new_sections} =
      resolve_content_transclusions(section.content, section.level, visited)

    {resolved_sections, resolved_content} =
      Enum.reduce(section.sections, {[], resolved_content}, fn
        section, {resolved_sections, resolved_content} ->
          case do_resolve_transclusions(section, visited) do
            {:transclusion_expansion, [], expanded_sections} ->
              {Enum.reverse(expanded_sections) ++ resolved_sections, resolved_content}

            {:transclusion_expansion, expanded_content, expanded_sections} ->
              case resolved_sections do
                [] ->
                  {
                    Enum.reverse(expanded_sections) ++ resolved_sections,
                    resolved_content ++ expanded_content
                  }

                [last | rest] ->
                  {
                    Enum.reverse(expanded_sections) ++ [append(last, expanded_content) | rest],
                    resolved_content
                  }
              end

            resolved_section ->
              {List.wrap(resolved_section) ++ resolved_sections, resolved_content}
          end
      end)

    resolved_sections = new_sections ++ Enum.reverse(resolved_sections)

    case resolve_transclusion_header(section, visited) do
      {:transclusion_expansion, expanded_content, []} ->
        {:transclusion_expansion, expanded_content ++ resolved_content, resolved_sections}

      {:transclusion_expansion, expanded_content, expanded_sections} ->
        {
          :transclusion_expansion,
          expanded_content,
          List.update_at(expanded_sections, -1, &append(&1, resolved_content, resolved_sections))
        }

      nil ->
        %__MODULE__{
          section
          | content: resolved_content,
            sections: resolved_sections
        }

      resolved_section ->
        resolved_section = append(resolved_section, resolved_content, resolved_sections)

        unless(empty_content?(resolved_section), do: resolved_section)
    end
  end

  defp resolve_content_transclusions(content, level, visited) do
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
          if extract_document_name(target) in visited do
            raise "recursive cycle during transclusion resolution of #{target}"
          end

          if resolved_transclusion = transcluded_content(target, level + 1, visited) do
            {new_content, [resolved_transclusion | new_sections]}
          else
            acc_append(transclusion, acc)
          end

        content, acc ->
          acc_append(content, acc)
      end)

    {Enum.reverse(new_content), Enum.reverse(new_sections)}
  end

  defp acc_append(content, {new_content, []}),
    do: {[content | new_content], []}

  defp acc_append(content, {new_content, [current | rest]}),
    do: {new_content, [append(current, content) | rest]}

  defp append(section, new_content, new_sections \\ [])

  defp append(%__MODULE__{} = section, [], []), do: section

  defp append(%__MODULE__{sections: []} = section, ast, []) do
    %__MODULE__{section | content: section.content ++ List.wrap(ast)}
  end

  defp append(%__MODULE__{} = section, ast, []) do
    %__MODULE__{section | sections: List.update_at(section.sections, -1, &append(&1, ast))}
  end

  defp append(%__MODULE__{} = section, ast, new_sections) do
    with_new_content = append(section, ast)
    %__MODULE__{with_new_content | sections: with_new_content.sections ++ new_sections}
  end

  defp resolve_transclusion_header(%__MODULE__{header: header} = section, visited) do
    case Enum.reverse(header.children) do
      [%Panpipe.AST.Image{title: "wikilink", target: target} | rest] ->
        if extract_document_name(target) in visited do
          raise "recursive cycle during transclusion resolution of #{target}"
        end

        empty_header? = rest == []

        level =
          cond do
            not empty_header? -> section.level
            section.level > 1 -> section.level - 1
            true -> raise TopLevelEmptyHeaderTransclusionError
          end

        if resolved_transclusion = transcluded_content(target, level, visited) do
          if empty_header? do
            {:transclusion_expansion, resolved_transclusion.content,
             resolved_transclusion.sections}
          else
            new_header = %Panpipe.AST.Header{
              header
              | children: rest |> trim_leading_ast() |> Enum.reverse(),
                attr: nil
            }

            %__MODULE__{
              resolved_transclusion
              | header: new_header,
                title: header_title(new_header)
            }
          end
        end

      _ ->
        nil
    end
  end

  defp transcluded_content(target, level, visited) do
    {document_name, section_title} = parse_document_name(target)

    with {:ok, document_struct} <- transcluded_document_struct(document_name),
         {:ok, section} <- fetch_transcluded_content(document_struct, section_title) do
      case do_resolve_transclusions(section, [document_name | visited]) do
        {:transclusion_expansion, _, _} ->
          raise "transclusion of transclusion sections are not allowed"

        resolved_section ->
          resolved_section
          |> remove_comments()
          |> set_level(level)
      end
    else
      {:error, error} ->
        Logger.warning("failed to load [[#{document_name}]] during resolution: #{inspect(error)}")
        nil
    end
  end

  defp transcluded_document_struct(document_name) do
    case Document.Loader.load(document_name) do
      {:ok, %{sections: _} = document} ->
        {:ok, document}

      {:ok, document} ->
        DocumentStruct.parse(document.content)

      {:error, error} when error in [:magma_type_missing, :invalid_front_matter] ->
        with {:ok, body} <-
               document_name
               # We can assume here that the file exists, because the initial loader has found the file already
               |> Vault.document_path()
               |> File.read() do
          DocumentStruct.parse(body)
        end

      {:error, _} = error ->
        error
    end
  end

  defp fetch_transcluded_content(%Concept{} = concept, nil) do
    {:ok, DocumentStruct.main_section(concept)}
  end

  defp fetch_transcluded_content(%DocumentStruct{sections: [section]}, nil) do
    {:ok, section}
  end

  defp fetch_transcluded_content(%DocumentStruct{sections: [first | rest]}, nil) do
    {:ok,
     %__MODULE__{
       first
       | sections:
           Enum.map(first.sections, &shift_level(&1, 1)) ++
             Enum.map(rest, &shift_level(&1, 1))
     }}
  end

  defp fetch_transcluded_content(%{sections: _} = document_struct, section_title) do
    if section = DocumentStruct.section_by_title(document_struct, section_title) do
      {:ok, section}
    else
      {:error, "No section #{section_title} found"}
    end
  end

  defp parse_document_name(name) do
    case String.split(name, "#") do
      [document_name] -> {document_name, nil}
      [document_name, section] -> {document_name, section}
    end
  end

  def extract_document_name(name), do: name |> parse_document_name() |> elem(0)

  defp trim_leading_ast([%Panpipe.AST.Space{} | rest]), do: trim_leading_ast(rest)
  defp trim_leading_ast(ast), do: ast

  def remove_comments(%__MODULE__{} = section) do
    %__MODULE__{
      section
      | content: Enum.flat_map(section.content, &List.wrap(do_remove_comments(&1))),
        sections: Enum.map(section.sections, &remove_comments/1)
    }
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

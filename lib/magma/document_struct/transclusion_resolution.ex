defmodule Magma.DocumentStruct.TransclusionResolution do
  @moduledoc false

  alias Magma.{DocumentStruct, Document, Concept, Vault}
  alias Magma.DocumentStruct.Section

  require Logger

  def resolve_transclusions(document_struct_or_section, visited \\ [])

  def resolve_transclusions(%DocumentStruct{} = document_struct, visited) do
    {new_content, new_sections} =
      resolve_inline_transclusions(document_struct.prologue, 1, visited)

    %DocumentStruct{
      document_struct
      | prologue: new_content,
        sections:
          new_sections ++
            Enum.map(document_struct.sections, &resolve_transclusions(&1, visited))
    }
  end

  def resolve_transclusions(%Section{} = section, visited) do
    {resolved_content, new_sections} =
      resolve_inline_transclusions(section.content, section.level, visited)

    resolved_sections =
      new_sections ++
        Enum.flat_map(section.sections, &(&1 |> resolve_transclusions(visited) |> List.wrap()))

    if resolved_section = resolve_transclusion_header(section, visited) do
      resolved_section =
        resolved_section
        |> append(resolved_content)
        |> Map.update!(:sections, &(&1 ++ resolved_sections))

      unless Section.empty_content?(resolved_section), do: resolved_section
    else
      %Section{
        section
        | content: resolved_content,
          sections: resolved_sections
      }
    end
  end

  def resolve_inline_transclusions(content, level, visited) do
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
        acc ->
          if extract_document_name(target) in visited do
            raise "recursive cycle during transclusion resolution of #{target}"
          end

          case transcluded_content(target, level, visited) do
            nil ->
              acc_append(acc, transclusion)

            %DocumentStruct{
              prologue: [],
              sections: [
                %Section{content: transcluded_content, sections: transcluded_sections}
                | more_transcluded_sections
              ]
            } ->
              acc
              |> acc_append(transcluded_content)
              |> acc_append(transcluded_sections)
              |> acc_append(Enum.map(more_transcluded_sections, &Section.shift_level(&1, 1)))

            %DocumentStruct{prologue: transcluded_content, sections: transcluded_sections} ->
              acc
              |> acc_append(transcluded_content)
              |> acc_append(Enum.map(transcluded_sections, &Section.shift_level(&1, 1)))

            %Section{content: transcluded_content, sections: transcluded_sections} ->
              acc
              |> acc_append(transcluded_content)
              |> acc_append(transcluded_sections)
          end

        content, acc ->
          acc_append(acc, content)
      end)

    {Enum.reverse(new_content), Enum.reverse(new_sections)}
  end

  defp acc_append(acc, []), do: acc

  defp acc_append({new_content, new_sections}, [%Section{} | _] = sections),
    do: {new_content, Enum.reverse(sections, new_sections)}

  defp acc_append({new_content, []}, content) when is_list(content),
    do: {Enum.reverse(content, new_content), []}

  defp acc_append({new_content, []}, content),
    do: {[content | new_content], []}

  defp acc_append({new_content, [current | rest]}, content),
    do: {new_content, [append(current, content) | rest]}

  defp append(%Section{sections: []} = section, ast) do
    %Section{section | content: section.content ++ List.wrap(ast)}
  end

  defp append(%Section{} = section, ast) do
    %Section{section | sections: List.update_at(section.sections, -1, &append(&1, ast))}
  end

  defp resolve_transclusion_header(%Section{header: header} = section, visited) do
    case Enum.reverse(header.children) do
      [%Panpipe.AST.Image{title: "wikilink", target: target} | rest] ->
        if extract_document_name(target) in visited do
          raise "recursive cycle during transclusion resolution of #{target}"
        end

        new_header =
          if rest != [] do
            %Panpipe.AST.Header{
              header
              | children: rest |> trim_leading_ast() |> Enum.reverse(),
                attr: nil
            }
          end

        case transcluded_content(target, section.level, visited) do
          nil ->
            nil

          %DocumentStruct{sections: [%Section{} = first_section | more_transcluded_sections]} ->
            if new_header do
              Section.set_header(first_section, new_header)
            else
              first_section
            end
            |> struct(
              sections:
                first_section.sections ++
                  Enum.map(more_transcluded_sections, &Section.shift_level(&1, 1))
            )

          %DocumentStruct{sections: [], prologue: content} ->
            Section.new(new_header || {section.level, target}, content)

          resolved_section ->
            if new_header do
              Section.set_header(resolved_section, new_header)
            else
              resolved_section
            end
        end

      _ ->
        nil
    end
  end

  defp transcluded_content(target, level, visited) do
    {document_name, section_title} = parse_document_name(target)

    with {:ok, document_struct} <- transcluded_document_struct(document_name) do
      case fetch_transcluded_content(document_struct, section_title) do
        {:ok, %DocumentStruct{} = document_struct} ->
          document_struct
          |> resolve_transclusions([document_name | visited])
          |> DocumentStruct.remove_comments()
          |> DocumentStruct.set_level(level)

        {:ok, section} ->
          section
          |> resolve_transclusions([document_name | visited])
          |> Section.remove_comments()
          |> Section.set_level(level)

        {:error, error} ->
          raise error
      end
    else
      {:error, error} ->
        Logger.warning("failed to load [[#{document_name}]] during resolution: #{inspect(error)}")
        nil
    end
  end

  defp transcluded_document_struct("Project") do
    {:ok, %DocumentStruct{prologue: [], sections: Magma.Config.project().sections}}
  end

  defp transcluded_document_struct("magma_config") do
    {:ok, %DocumentStruct{prologue: [], sections: Magma.Config.system().sections}}
  end

  defp transcluded_document_struct(document_name) do
    case Document.Loader.load(document_name) do
      {:ok, %Concept{} = concept} ->
        {:ok, %DocumentStruct{prologue: [], sections: concept.sections}}

      {:ok, document} ->
        with {:ok, document_struct} <- DocumentStruct.parse(document.content) do
          {:ok, %DocumentStruct{document_struct | prologue: []}}
        end

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

  defp fetch_transcluded_content(%DocumentStruct{prologue: [], sections: [section]}, nil) do
    {:ok, section}
  end

  defp fetch_transcluded_content(%DocumentStruct{} = document_struct, nil) do
    {:ok, document_struct}
  end

  defp fetch_transcluded_content(%DocumentStruct{} = document_struct, section_title) do
    if section = DocumentStruct.section_by_title(document_struct, section_title) do
      {:ok, section}
    else
      {:error, "No section #{section_title} found"}
    end
  end

  defp extract_document_name(name), do: name |> parse_document_name() |> elem(0)

  defp parse_document_name(name) do
    case String.split(name, "#") do
      [document_name] -> {document_name, nil}
      [document_name, section] -> {document_name, section}
    end
  end

  defp trim_leading_ast([%Panpipe.AST.Space{} | rest]), do: trim_leading_ast(rest)
  defp trim_leading_ast(ast), do: ast
end

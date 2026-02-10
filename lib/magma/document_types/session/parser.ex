defmodule Magma.Session.Parser do
  @moduledoc !"""
             Parses Session documents to extract typed sections separated by special markers.

             Separator format:
             ---
             ***Keyword***
             ---
             """

  alias Magma.{DocumentStruct, Session}

  @keywords ~w[Prompt Response Notes]

  @doc """
  Parses the Session document content and returns a list of typed parts.

  Returns `{:ok, parts}` where parts is a list of `{type, ast_nodes}` tuples.
  Content before the first separator is returned as `{:initial, ast_nodes}`.
  Returns `{:ok, [{:initial, ast_nodes}]}` if no separators are found.
  """
  @spec parse(binary()) :: {:ok, Session.parts()} | {:error, any()}
  def parse(content) when is_binary(content) do
    with {:ok, document} <-
           content
           |> String.trim()
           |> Panpipe.ast(from: DocumentStruct.pandoc_extension()) do
      {:ok, extract_parts(document.children)}
    end
  end

  # Extract parts by finding separator patterns with three accumulators:
  # - parts_acc: accumulated {type, content} tuples
  # - current_type: type from the last separator
  # - content_acc: nodes collected since last separator
  defp extract_parts(ast_nodes, parts_acc \\ [], current_type \\ nil, content_acc \\ [])

  defp extract_parts(
         [
           %Panpipe.AST.HorizontalRule{},
           %Panpipe.AST.Para{
             children: [
               %Panpipe.AST.Strong{
                 children: [%Panpipe.AST.Emph{children: [%Panpipe.AST.Str{string: keyword}]}]
               }
             ]
           },
           %Panpipe.AST.HorizontalRule{} | rest
         ],
         parts_acc,
         current_type,
         content_acc
       )
       when keyword in @keywords do
    type = keyword |> String.downcase() |> String.to_atom()

    extract_parts(rest, add_part(parts_acc, current_type, content_acc), type)
  end

  defp extract_parts([node | rest], parts_acc, current_type, content_acc) do
    extract_parts(rest, parts_acc, current_type, [node | content_acc])
  end

  defp extract_parts([], parts_acc, current_type, content_acc) do
    parts_acc
    |> add_part(current_type, content_acc)
    |> Enum.reverse()
  end

  # Add a part to the accumulator
  defp add_part(parts_acc, nil, []), do: parts_acc
  defp add_part(parts_acc, nil, content), do: [{:initial, Enum.reverse(content)} | parts_acc]
  defp add_part(parts_acc, _type, []), do: parts_acc
  defp add_part(parts_acc, type, content), do: [{type, Enum.reverse(content)} | parts_acc]
end

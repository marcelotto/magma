defmodule Magma.View do
  @moduledoc """
  Utility module with helper functions for creating the content of Magma documents.
  """

  alias Magma.{Concept, PromptResult, Artefact, Text, DocumentStruct}
  alias Magma.DocumentStruct.Section

  @doc """
  Creates an internal Obsidian link to the given document.

  The document can be given by name or as a `Magma.Document` struct.

  The optional second argument allows set an alternative label.


  ## Examples

      iex> Magma.View.link_to("Document")
      "[[Document]]"

      iex> Magma.View.link_to("Document", "Alt")
      "[[Document|Alt]]"

  """
  def link_to(document_or_target, label \\ nil)
  def link_to(%_{name: name}, label), do: link_to(name, label)
  def link_to(target, nil) when is_binary(target), do: "[[#{target}]]"
  def link_to(target, label) when is_binary(target), do: "[[#{target}|#{label}]]"

  def link_to_concept(document, section \\ nil),
    do: document |> Concept.from() |> link_to(section)

  def link_to_prompt(document, section \\ nil),
    do: document |> Artefact.Prompt.from() |> link_to(section)

  def link_to_prompt_result(document, section \\ nil),
    do: document |> PromptResult.from() |> link_to(section)

  def link_to_version(document, section \\ nil),
    do: document |> Artefact.Version.from() |> link_to(section)

  def link_to_preview(document, section \\ nil),
    do: document |> Text.Preview.from() |> link_to(section)

  @doc """
  Creates an Obsidian transclusion of the given document or section.

  The document can be given by name or as a `Magma.Document` struct.

  The optional second argument can be used to specify a specific
  section to be transcluded.

  ## Examples

      iex> Magma.View.transclude("Document")
      "![[Document|]]"

      iex> Magma.View.transclude("Document", "Section")
      "![[Document#Section|]]"

  """
  def transclude(document_or_target, section \\ nil)
  def transclude(%_{name: name}, title), do: transclude(name, title)
  def transclude(:title, :title), do: raise("invalid title")
  def transclude(target, :title), do: transclude(target, target)
  # We're adding the final '|' since Pandoc normalizes to this anyway
  def transclude(target, nil), do: "![[#{target}|]]"
  def transclude(target, section), do: "![[#{target}##{section}|]]"

  def transclude_concept(document, section \\ nil),
    do: document |> Concept.from() |> transclude(section)

  def transclude_prompt(document, section \\ nil),
    do: document |> Artefact.Prompt.from() |> transclude(section)

  def transclude_prompt_result(document, section \\ nil),
    do: document |> PromptResult.from() |> transclude(section)

  def transclude_version(document, section \\ nil),
    do: document |> Artefact.Version.from() |> transclude(section)

  def transclude_preview(document, section \\ nil),
    do: document |> Text.Preview.from() |> transclude(section)

  def include(document_or_section, subsection \\ nil, opts \\ [])
  def include(nil, _, _), do: nil

  def include(%Section{} = section, nil, opts) do
    section |> Section.to_markdown(opts) |> String.trim()
  end

  def include(%Section{} = section, subsection_path, opts) when is_list(subsection_path) do
    if subsection = get_in(section, subsection_path) do
      include(subsection, nil, opts)
    end
  end

  def include(%Section{} = section, subsection, opts) do
    if subsection = Section.section_by_title(section, subsection) do
      include(subsection, nil, opts)
    end
  end

  def include(%Concept{} = concept, nil, opts) do
    concept
    |> Concept.description_section()
    |> include(nil, opts)
  end

  def include(%Concept{} = concept, :title, opts) do
    include(concept, concept.title, opts)
  end

  def include(%Concept{} = concept, subsection, opts) do
    concept
    |> DocumentStruct.section_by_title(subsection)
    |> include(nil, opts)
  end

  def include(%_document_type{content: content}, subsection, opts) do
    case DocumentStruct.parse(content) do
      {:ok, document_struct} ->
        subsection =
          if subsection in [:title, nil],
            do: DocumentStruct.title(document_struct),
            else: subsection

        cond do
          subsection == :all ->
            # DocumentStruct.to_markdown() does not support opts yet
            document_struct |> DocumentStruct.to_markdown() |> String.trim()

          section = DocumentStruct.section_by_title(document_struct, subsection) ->
            include(section, nil, opts)

          true ->
            nil
        end

      {:error, error} ->
        raise error
    end
  end

  def include_context_knowledge(%Concept{} = concept) do
    concept
    |> Concept.context_knowledge_section()
    |> include(nil, header: false, level: 3, remove_comments: true)
  end

  def comment(text) do
    """
    <!--
    #{String.trim_trailing(text)}
    -->
    """
    |> String.trim_trailing()
  end

  def callout(text, type \\ "info") do
    """
    >[!#{type}]
    >#{String.replace(text, "\n", "\n>")}
    """
    |> String.trim_trailing()
  end

  def button(label, command, opts \\ []) do
    """
    ```button
    name #{label}
    type command
    action Shell commands: Execute: #{command}
    color #{opts[:color] || "default"}
    ```
    """
    |> String.trim_trailing()
  end

  def delete_current_file_button do
    """
    ```button
    name Delete
    type command
    action Delete current file
    color red
    ```
    """
    |> String.trim_trailing()
  end

  def yaml_list(list) do
    "[" <> (list |> List.wrap() |> Enum.join(", ")) <> "]"
  end

  def yaml_nested_map(%_{} = struct) do
    struct |> Map.from_struct() |> yaml_nested_map()
  end

  def yaml_nested_map(map) when is_map(map) do
    Jason.encode!(map)
  end

  def prompt_results_table do
    """
    ```dataview
    TABLE
    	tags AS Tags,
    	magma_generation_type AS Generator,
    	magma_generation_params AS Params
    WHERE magma_prompt = [[]]
    ```
    """
    |> String.trim_trailing()
  end
end

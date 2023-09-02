defmodule Magma.DocumentStruct do
  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}

  @pandoc_extension {:markdown,
                     %{
                       disable: [:yaml_metadata_block, :multiline_tables],
                       enable: [:wikilinks_title_after_pipe]
                     }}
  def pandoc_extension, do: @pandoc_extension

  def new(args) do
    struct(__MODULE__, args)
  end

  defdelegate parse(content), to: Parser

  defdelegate fetch(document_struct, key), to: Section

  def section_by_title(%{sections: sections}, title) do
    Enum.find_value(sections, &Section.section_by_title(&1, title))
  end

  def title(%{sections: [%Section{title: title} | _]}) do
    String.trim(title)
  end

  def ast(%{sections: sections}, opts \\ []) do
    Enum.flat_map(sections, &Section.ast(&1, opts))
  end
end

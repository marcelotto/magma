defmodule Magma.DocumentStruct do
  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}

  @pandoc_extension {:markdown,
   %{
     enable: [:wikilinks_title_after_pipe],
     disable: [
       :yaml_metadata_block,
       :multiline_tables,
       # for unknown reasons Pandoc sometimes generates header attributes where there should be none, when this is enabled
       :header_attributes
     ]
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

  def main_section(%{sections: [%Section{} = main_section | _]}), do: main_section

  def title(document) do
    String.trim(main_section(document).title)
  end

  def ast(%{sections: sections}, opts \\ []) do
    Enum.flat_map(sections, &Section.ast(&1, opts))
  end
end

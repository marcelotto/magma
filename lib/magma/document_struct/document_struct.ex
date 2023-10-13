defmodule Magma.DocumentStruct do
  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}
  alias Magma.DocumentStruct.TransclusionResolution

  @pandoc_extension {:markdown,
   %{
     enable: [:wikilinks_title_after_pipe],
     disable: [
       :multiline_tables,
       :smart,
       # for unknown reasons Pandoc sometimes generates header attributes where there should be none, when this is enabled
       :header_attributes,
       # this extension causes HTML comments to be converted to code blocks
       :raw_attribute
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
  def main_section(%{sections: []}), do: nil

  def title(document) do
    if main_section = main_section(document) do
      String.trim(main_section.title)
    end
  end

  def to_string(%{prologue: prologue} = document) do
    %Panpipe.Document{children: prologue ++ ast(document)}
    |> Panpipe.Pandoc.Conversion.convert(to: @pandoc_extension, wrap: "none")
  end

  defp ast(%{sections: sections}, opts \\ []) do
    Enum.flat_map(sections, &Section.ast(&1, opts))
  end

  def set_level(%__MODULE__{} = document_struct, level) do
    %__MODULE__{
      document_struct
      | sections: Enum.map(document_struct.sections, &Section.set_level(&1, level))
    }
  end

  def remove_comments(%__MODULE__{} = document_struct) do
    %__MODULE__{
      document_struct
      | prologue: Section.remove_comments(document_struct.prologue),
        sections: Enum.map(document_struct.sections, &Section.remove_comments/1)
    }
  end

  defdelegate resolve_transclusions(document_struct), to: TransclusionResolution
end

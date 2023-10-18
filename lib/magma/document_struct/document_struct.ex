defmodule Magma.DocumentStruct do
  @moduledoc """
  Provides an abstract representation of a Markdown document structured based on the Pandoc AST.

  The `Magma.DocumentStruct` module provides an Elixir struct for representing
  the contents of a Markdown document as an Abstract Syntax Tree (AST) based
  on the Pandoc AST. The struct is designed to access the individual sections
  including their subsections and facilitate the transclusion resolution feature,
  which is essential for the prompt generation in Magma.

  The `Magma.DocumentStruct` struct consists of a prologue, which is the
  header-less text before the first section, and all sections of level 1
  (which in turn consist of sections of level 2 and so on).
  The core functionalities related to sections are implemented in the
  `Magma.DocumentStruct.Section` module. The `Magma.DocumentStruct` acts as a
  wrapper around this recursive section structure and delegates most of its
  functions to the said module.
  """

  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}
  alias Magma.DocumentStruct.TransclusionResolution

  @type t :: %__MODULE__{
          prologue: [Panpipe.AST.Node.t()],
          sections: [Section.t()]
        }

  @type compatible ::
          %{
            prologue: [Panpipe.AST.Node.t()],
            sections: [Section.t()]
          }
          | Magma.Concept.t()

  @doc false
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

  @doc false
  @spec new(keyword) :: t()
  def new(args) do
    struct(__MODULE__, args)
  end

  @doc """
  Parses the given content into a `Magma.DocumentStruct`.
  """
  @spec parse(binary) :: {:ok, t()} | {:error, any}
  defdelegate parse(content), to: Parser

  @doc """
  Fetches the section with the given `title` and returns it in an ok tuple.

  If no section with `title` exists, it returns `:error`.

  This implements `Access.fetch/2` function, so that the `document_struct[title]`
  syntax and the `Kernel` macros for accessing nested data structures like
  `get_in/2` are supported.

  This function only searches sections directly under the given section.
  For a recursive search, use `section_by_title/2`.
  """
  defdelegate fetch(document_struct, title), to: Section

  @doc """
  Fetches the first section with the given `title`.

  Unlike `fetch/2`, this function performs a recursive search throughout the
  document to find the desired section.
  """
  @spec section_by_title(t() | compatible(), binary) :: Section.t() | nil
  def section_by_title(%{sections: sections}, title) do
    Enum.find_value(sections, &Section.section_by_title(&1, title))
  end

  @doc """
  Returns the first section.

  Assuming that the first section with header level 1 is the main section.
  """
  @spec main_section(t() | compatible()) :: Section.t() | nil
  def main_section(%{sections: [%Section{} = main_section | _]}), do: main_section
  def main_section(%{sections: []}), do: nil

  @doc """
  Extracts and returns the title of the `main_section/1`.
  """
  @spec title(t() | compatible()) :: binary | nil
  def title(document_struct) do
    if main_section = main_section(document_struct) do
      String.trim(main_section.title)
    end
  end

  @doc """
  Converts the given `document_struct` back into a Markdown string.
  """
  @spec to_markdown(t() | compatible()) :: binary
  def to_markdown(%{prologue: prologue} = document) do
    %Panpipe.Document{children: prologue ++ ast(document)}
    |> Panpipe.Pandoc.Conversion.convert(to: @pandoc_extension, wrap: "none")
  end

  defp ast(%{sections: sections}, opts \\ []) do
    Enum.flat_map(sections, &Section.ast(&1, opts))
  end

  @doc """
  Sets the header level for all sections within the document.

  See `Magma.DocumentStruct.Section.set_level/2` which does the same
  on a section level.
  """
  @spec set_level(t(), non_neg_integer()) :: t()
  def set_level(%__MODULE__{} = document_struct, level) do
    %__MODULE__{
      document_struct
      | sections: Enum.map(document_struct.sections, &Section.set_level(&1, level))
    }
  end

  @doc """
  Removes all comment blocks from the given `document_struct`.

  See `Magma.DocumentStruct.Section.remove_comments/1` which does the same
  on a section level.
  """
  @spec remove_comments(t()) :: t()
  def remove_comments(%__MODULE__{} = document_struct) do
    %__MODULE__{
      document_struct
      | prologue: Section.remove_comments(document_struct.prologue),
        sections: Enum.map(document_struct.sections, &Section.remove_comments/1)
    }
  end

  @doc """
  Processes and resolves transclusions within the given `document_struct`.

  See `Magma.DocumentStruct.Section.resolve_transclusions/1` which does the same
  on a section level.
  """
  @spec resolve_transclusions(t()) :: t()
  defdelegate resolve_transclusions(document_struct), to: TransclusionResolution
end

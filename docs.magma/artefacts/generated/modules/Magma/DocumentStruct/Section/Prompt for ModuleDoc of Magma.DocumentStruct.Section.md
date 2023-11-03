---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.DocumentStruct.Section]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-18 17:14:21
tags: [magma-vault]
aliases: []
---

**Generated results**

```dataview
TABLE
	tags AS Tags,
	magma_generation_type AS Generator,
	magma_generation_params AS Params
WHERE magma_prompt = [[]]
```

Final version: [[ModuleDoc of Magma.DocumentStruct.Section]]

**Actions**

```button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
```
```button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
```
```button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
```
```button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
```

# Prompt for ModuleDoc of Magma.DocumentStruct.Section

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

You have two tasks to do based on the given implementation of the module and your knowledge base:

1. generate the content of the `@doc` strings of the public functions
2. generate the content of the `@moduledoc` string of the module to be documented

Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

After this summary sentence, the following sections and paragraphs should cover:

- What's the purpose of this module/function?
- For moduledocs: What are the main function(s) of this module?
- If possible, an example usage in an "Example" section using an indented code block
- configuration options (if there are any)
- everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

```markdown
## Function docs

### `function/1`

Summary sentence

Body

## Moduledoc

Summary sentence

Body
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response (unless its explicitly requested to include some parts of it) as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]

##### `Magma.DocumentStruct` ![[Magma.DocumentStruct#Description|]]


## Request

![[Magma.DocumentStruct.Section#ModuleDoc prompt task|]]

### Description of the module `Magma.DocumentStruct.Section` ![[Magma.DocumentStruct.Section#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.DocumentStruct.Section do
  defstruct [:title, :level, :header, :content, :sections]

  @type t :: %__MODULE__{
          title: binary,
          level: integer,
          header: Panpipe.AST.Header.t(),
          content: [Panpipe.AST.Node.t()],
          sections: [t()]
        }

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.TransclusionResolution
  alias Panpipe.AST.Header

  @default_link_resolution_style :plain

  @doc """
  Creates a section.
  """
  @spec new(Header.t(), [Panpipe.AST.Node.t()], [t()]) :: t()
  def new(%Header{} = header, content, sections) do
    %__MODULE__{
      content: content,
      sections: sections
    }
    |> set_header(header)
  end

  def set_header(%__MODULE__{} = section, %Header{} = header) do
    %__MODULE__{
      section
      | header: header,
        title: header_title(header),
        level: header.level
    }
  end

  defp header_title(%Header{children: children}) do
    %Panpipe.Document{children: [%Panpipe.AST.Para{children: children}]}
    # TODO: use new way to enabling and disabling extensions on format functions
    #      |> Panpipe.to_markdown()
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension())
    |> String.trim()
  end

  @doc """
  Fetches the section with the given `title` and returns it in an ok tuple.

  If no section with `section` exists, it returns `:error`.

  This implements `Access.fetch/2` function, so that the `section[title]`
  syntax is supported.

  Note that only sections directly under the given section is searched.
  If a recursive search is needed, `section_by_title/2` should be used.
  """
  @spec fetch(t(), binary) :: {:ok, t()} | :error
  def fetch(%_{sections: sections}, title) do
    Enum.find_value(sections, fn
      %{title: ^title} = section -> {:ok, section}
      _ -> nil
    end) || :error
  end

  @doc """
  Returns if the given section is empty, i.e. it has no `content` and nested `sections`.
  """
  @spec empty?(t()) :: boolean
  def empty?(%__MODULE__{content: [], sections: []}), do: true
  def empty?(%__MODULE__{}), do: false

  @doc """
  Return if given section consists solely of subsection headers.
  """
  @spec empty_content?(t()) :: boolean
  def empty_content?(%__MODULE__{} = section) do
    section.content == [] && Enum.all?(section.sections, &empty_content?/1)
  end

  @doc """
  Fetches the first section with the given `title`.

  Other than accessing the sections with the `fetch/2`, this searches the
  sections recursively.
  """
  @spec section_by_title(t(), binary) :: t() | nil
  def section_by_title(section, title)

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

  @doc """
  Returns the section as
  """
  def to_string(%__MODULE__{} = section, opts \\ []) do
    %Panpipe.Document{children: ast(section, opts)}
    # TODO: use new way to enabling and disabling extensions on format functions
    #      |> Panpipe.to_markdown()
    |> Panpipe.Pandoc.Conversion.convert(to: DocumentStruct.pandoc_extension(), wrap: "none")
  end

  @doc """
  Changes the header level of `section` to the given `level`.

  Computes the difference to the current level of `section` and shifts the
  level recursively on all subsections using `shift_level/2`.
  """
  @spec set_level(t(), non_neg_integer()) :: t()
  def set_level(section, level)

  def set_level(%__MODULE__{} = section, nil), do: section

  def set_level(%__MODULE__{}, new_level) when new_level < 0,
    do: raise("invalid header level: #{new_level}")

  def set_level(%__MODULE__{level: level} = section, new_level),
    do: shift_level(section, new_level - level)

  @doc """
  Shifts the header level of `section` by the given `shift_level`.

  All subsections are shifted recursively.
  """
  @spec shift_level(t(), integer()) :: t()
  def shift_level(section, shift_level)

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

  defdelegate resolve_transclusions(section), to: TransclusionResolution

  def resolve_links(%__MODULE__{} = section, opts \\ []) do
    do_resolve_links(
      section,
      opts
      |> Keyword.get(:style)
      |> link_resolution_style()
    )
  end

  defp do_resolve_links(section, style) do
    %__MODULE__{
      section
      | content: Enum.map(section.content, &transform_links(&1, style)),
        sections: Enum.map(section.sections, &do_resolve_links(&1, style))
    }
  end

  defp transform_links(ast, style) do
    Panpipe.transform(ast, fn
      %Panpipe.AST.Link{title: "wikilink", children: children} -> style.(children)
      _ -> nil
    end)
  end

  defp link_resolution_style(nil), do: default_link_resolution_style() |> link_resolution_style()
  defp link_resolution_style(:plain), do: & &1
  defp link_resolution_style(:emph), do: &%Panpipe.AST.Emph{children: &1}
  defp link_resolution_style(:strong), do: &%Panpipe.AST.Strong{children: &1}
  defp link_resolution_style(:underline), do: &%Panpipe.AST.Underline{children: &1}
  defp link_resolution_style(fun) when is_function(fun), do: fun

  defp default_link_resolution_style do
    Application.get_env(:magma, :link_resolution_style, @default_link_resolution_style)
  end

  def remove_comments(%__MODULE__{} = section) do
    %__MODULE__{
      section
      | content: remove_comments(section.content),
        sections: Enum.map(section.sections, &remove_comments/1)
    }
  end

  def remove_comments(content) when is_list(content) do
    Enum.flat_map(content, &List.wrap(do_remove_comments(&1)))
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

```

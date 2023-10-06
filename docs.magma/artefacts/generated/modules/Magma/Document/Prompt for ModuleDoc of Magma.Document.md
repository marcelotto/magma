---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Document]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.2}
created_at: 2023-10-06 16:03:18
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

Final version: [[ModuleDoc of Magma.Document]]

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

# Prompt for ModuleDoc of Magma.Document

## System prompt

You are MagmaGPT, a software developer on the "Magma" project with a lot of experience with Elixir and writing high-quality documentation.

Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

```markdown
## Moduledoc

The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


## Function docs

In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

### `function/1`

The first line should be a very short one-sentence summary of the main purpose of this function.

Then follows the main body of the function documentation.
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]


## Request

### ![[Magma.Document#ModuleDoc prompt task|]]

### Description of the module `Magma.Document` ![[Magma.Document#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Document do
  alias Magma.Vault
  alias Magma.View

  import Magma.Utils, only: [init_fields: 2]

  @type t ::
          Magma.Concept.t()
          | Magma.Prompt.t()
          | Magma.Artefact.Prompt.t()
          | Magma.PromptResult.t()
          | Magma.Artefact.Version.t()
          | Magma.Text.Preview.t()

  @callback from(t() | {Concept.t(), Artefact.t()}) :: t() | binary

  @callback from!(t() | {Concept.t(), Artefact.t()}) :: t()

  @callback build_path(t()) :: {:ok, Path.t()}

  @callback title(t()) :: binary

  @callback load_document(t()) :: {:ok, t()} | {:error, any}

  @callback render_front_matter(t()) :: binary

  @fields [
    # the path of this document
    path: nil,
    # the name of the file (used for links)
    name: nil,
    # the raw text of the document without the YAML front matter
    content: nil,
    tags: nil,
    aliases: nil,
    created_at: nil,
    # additional YAML front matter
    custom_metadata: %{}
  ]
  def fields, do: @fields

  defmacro __using__(opts) do
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Document
      alias Magma.Document

      defstruct Magma.Document.fields() ++ unquote(additional_fields)

      @impl true
      def from!(document) do
        case from(document) do
          %_{} = result -> result
          name when is_binary(name) -> load!(name)
          other -> other
        end
      end

      def load(%__MODULE__{} = document), do: Document.Loader.load(document)
      def load(path), do: Document.Loader.load(__MODULE__, path)
      def load_linked(name), do: Document.Loader.load_linked(__MODULE__, name)

      def load!(document_or_path) do
        case load(document_or_path) do
          {:ok, document} -> document
          {:error, error} -> raise error
        end
      end
    end
  end

  @doc false
  def init(%_document_type{} = document, fields \\ []) do
    init_fields(
      document,
      [
        created_at: now(),
        tags: :magma |> Application.get_env(:default_tags) |> List.wrap(),
        aliases: []
      ]
      |> Keyword.merge(fields)
    )
  end

  @doc false
  def init_path(%document_type{} = document) do
    case apply(document_type, :build_path, [document]) do
      {:ok, path} -> {:ok, %{document | path: path, name: name_from_path(path)}}
      {:error, _} = error -> error
      undefined -> raise "Undefined result: #{inspect(undefined)}"
    end
  end

  @doc false
  def name_from_path(path) do
    Path.basename(path, Path.extname(path))
  end

  def create(%_document_type{} = document, opts \\ []) do
    cond do
      Magma.MixHelper.create_file(document.path, full_content(document), opts) ->
        Vault.index(document)

        {:ok, document}

      Keyword.get(opts, :ok_skipped, false) ->
        {:ok, document}

      true ->
        {:skipped, document}
    end
  end

  def save(%_document_type{} = document, opts \\ []) do
    with :ok <- Magma.MixHelper.save_file(document.path, full_content(document), opts) do
      {:ok, document}
    end
  end

  defp full_content(document) do
    render_front_matter(document) <> document.content
  end

  def render_front_matter(%document_type{} = document) do
    """
    ---
    magma_type: #{type_name(document_type)}
    #{document_type.render_front_matter(document)}
    created_at: #{document.created_at}
    tags: #{View.yaml_list(document.tags)}
    aliases: #{View.yaml_list(document.aliases)}
    ---
    """
  end

  def recreate(%document_type{} = document) do
    document
    |> reset_document()
    |> document_type.create(force: true)
  end

  def recreate!(document) do
    case recreate(document) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  defp reset_document(document) do
    %{document | content: nil, created_at: nil}
  end

  # an AST transformation would be better, but does an implicit normalization
  def content_without_prologue(document) do
    content = document.content

    case String.split(content, ~r{^\#.*\n}m, parts: 2) do
      [_, stripped_content] -> String.trim(stripped_content)
      _ -> raise "invalid document #{document.path}: no title header found"
    end
  end

  @doc false
  def now, do: NaiveDateTime.local_now()

  @doc """
  Returns the document type name for the given document.

  ## Example

      iex> Magma.Document.type_name(Magma.Concept)
      "Concept"

      iex> Magma.Document.type_name(Magma.Prompt)
      "Prompt"

      iex> Magma.Document.type_name(Magma.Artefact.Prompt)
      "Artefact.Prompt"

      iex> Magma.Document.type_name(Magma.PromptResult)
      "PromptResult"

      iex> Magma.Document.type_name(Magma.Artefact.Version)
      "Artefact.Version"

      iex> Magma.Document.type_name(Magma.Text.Preview)
      "Text.Preview"

      iex> Magma.Document.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Document type: Magma.Vault

      iex> Magma.Document.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Document type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Document type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Document type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the document module for the given string.

  ## Example

      iex> Magma.Document.type("Concept")
      Magma.Concept

      iex> Magma.Document.type("Artefact.Prompt")
      Magma.Artefact.Prompt

      iex> Magma.Document.type("Vault")
      nil

      iex> Magma.Document.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :build_path, 1)
  end
end

```

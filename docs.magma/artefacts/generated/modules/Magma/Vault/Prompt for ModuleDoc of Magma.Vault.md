---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Vault]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 14:36:52
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

Final version: [[ModuleDoc of Magma.Vault]]

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

# Prompt for ModuleDoc of Magma.Vault

## System prompt

![[Magma.System.config#Persona|]]

![[ModuleDoc.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.config#Context knowledge|]]

![[ModuleDoc.config#Context knowledge|]]

![[Magma.Vault#Context knowledge|]]


## Request

![[Magma.Vault#ModuleDoc prompt task|]]

### Description of the module `Magma.Vault` ![[Magma.Vault#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Vault do
  @moduledoc """
  A specialized Obsidian vault with directories for the Magma-specific documents.

  The `Magma.Vault` module serves as a representation and utility module for a Magma vault - a specialized Obsidian vault that resides in an Elixir project. This vault is more than just a collection of Markdown documents; it houses Magma documents, which are special kinds of Markdown documents with specific paths and purposes. The vault itself can be stored by default in the `docs.magma/` directory of an Elixir project but can be reconfigured as needed (see `path/0`).

  Main functions of this module include:

  - Retrieving paths within the vault, like the base path, template paths, concept paths, etc.
  - Creating and initializing a new vault (`create/3`).
  - Synchronizing the vault with the project's codebase (`sync/1`).
  - Indexing documents by name (`index/1`).
  - Fetching details of documents, such as their path (`document_path/1`) or type (`document_type/1`) .

  """

  alias Magma.Document
  alias Magma.Vault.Index

  @default_path "docs.magma"
  @concept_path_prefix "concepts"
  @artefact_path_prefix "artefacts"
  @artefact_generation_path_prefix Path.join(@artefact_path_prefix, "generated")
  @artefact_version_path_prefix Path.join(@artefact_path_prefix, "final")

  @template_path_prefix "templates"
  @custom_prompt_template_name "custom_prompt.md"

  @doc """
  Returns the application configured path to the vault.

  Unless specified otherwise, the path is the `#{@default_path}` directory
  inside the project directory.

  It can be changed with in your `config.exs` file like this:

      config :magma,
        dir: "custom_dir"

  Note, that this configuration should be environment-independent.
  Unless you're working on Magma itself, you don't want a test-specific vault,
  since the vault collects knowledge about your code in its entirety.
  """
  @spec path :: Path.t()
  def path, do: Application.get_env(:magma, :dir, @default_path) |> Path.expand()

  @doc """
  Constructs a complete path by joining the specified `segments` to the root vault `path/0`.

  Most of the time one of the more document type-specific functions is more suitable.

  ### Example

      Magma.Vault.path("directory")
      # returns: "/path/to/project/docs.magma/directory"

      Magma.Vault.path(["some", "directory"])
      # returns: "/path/to/project/docs.magma/some/directory"

  """
  @spec path(binary | [binary]) :: Path.t()
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  @doc """
  Returns the Vault path of the directory for templates.
  """
  @spec template_path :: Path.t()
  def template_path, do: path(@template_path_prefix)

  @doc """
  Constructs a complete template path by joining the specified `segments` to the `template_path/0`.

  ### Example

      Magma.Vault.template_path("some_template.md")
      # returns: "/path/to/project/docs.magma/templates/some_template.md"

  """
  @spec template_path(binary | [binary]) :: Path.t()
  def template_path(segments), do: Path.join([template_path() | List.wrap(segments)])

  @doc """
  Returns the Vault path for the custom prompt template.
  """
  @spec custom_prompt_template_path :: Path.t()
  def custom_prompt_template_path, do: template_path(@custom_prompt_template_name)

  @doc """
  Returns the Vault path of the directory for `Magma.Concept` documents.
  """
  @spec concept_path :: Path.t()
  def concept_path, do: path(@concept_path_prefix)

  @doc """
  Constructs a complete path for `Magma.Concept` documents by joining the specified `segments` to the `concept_path/0`.
  """
  @spec concept_path(binary | [binary]) :: Path.t()
  def concept_path(segments), do: Path.join([concept_path() | List.wrap(segments)])

  @doc """
  Returns the Vault path of the directory for `Magma.Artefact.Prompt` documents.
  """
  @spec artefact_generation_path :: Path.t()
  def artefact_generation_path, do: path(@artefact_generation_path_prefix)

  @doc """
  Constructs a complete path for `Magma.Artefact.Prompt` documents by joining the specified `segments` to the `artefact_generation_path/0`.
  """
  @spec artefact_generation_path(binary | [binary]) :: Path.t()
  def artefact_generation_path(segments),
    do: Path.join([artefact_generation_path() | List.wrap(segments)])

  @doc """
  Returns the Vault path of the directory for `Magma.Artefact.Version` documents.
  """
  @spec artefact_version_path :: Path.t()
  def artefact_version_path, do: path(@artefact_version_path_prefix)

  @doc """
  Constructs a complete path for `Magma.Artefact.Version` documents by joining the specified `segments` to the `artefact_generation_path/0`.
  """
  @spec artefact_version_path(binary | [binary]) :: Path.t()
  def artefact_version_path(segments),
    do: Path.join([artefact_version_path() | List.wrap(segments)])

  @doc """
  Creates and initializes a new vault.

  The `project_name` is a mandatory parameter.
  The `base_vault` specifies the `Magma.Vault.BaseVault` to be used for
  initializing the new Magma vault. It can be specified with any of arguments
  accepted by `Magma.Vault.BaseVault.path/1`.

  Available `opts`:

  - `:force` (default: `false`): allow to force creation even if a vault already exists
  - `:code_sync` (default: `true`): perform an initial code `sync/1`


  Returns `:ok` if the vault is successfully created or an error tuple if
  there's an error during the vault creation process.
  """
  @spec create(binary, base_vault :: Magma.Vault.BaseVault.theme() | Path.t() | nil, keyword) ::
          :ok | {:error, any}
  defdelegate create(project_name, base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

  @doc """
  Synchronizes the `Magma.Matter.Module` related documents with the latest state of the codebase.

  All modules in the code base are determined and for each one the following
  `Magma.Document`s created (unless they exist already or the `:all` option is set):

  - a `Magma.Concept`
  - `Magma.Artefact.Prompt`s for all `Magma.Artefact`s for `Magma.Matter.Module`
    (as specified by `Magma.Matter.Module.artefacts/0`)

  Available options:

  - `:all` (default: `false`) - when set to `true` also syncs modules for
    already existing documents
  - `force` (default: `false`) - when set to `true` overwrites all existing
    documents without asking the user
  """
  @spec sync(keyword) :: :ok | {:error, any}
  defdelegate sync(opts \\ []), to: Magma.Vault.CodeSync

  @doc """
  Indexes the provided document by its name.

  This function indexes a given `Magma.Document` to enable fast access to it by
  its name in the `document_path/1` function or the `load/1` functions of
  `Magma.Document`s.
  """
  defdelegate index(document), to: Magma.Vault.Index, as: :add

  @doc """
  Return the path of an existing document.

  When given a path it checks if there actually exists a document at this path.
  When given a document name (without file extension) it trys to fetch the path
  from the index.

  Returns `nil`, if no file exists at the given path or no document with the
  given name is indexed.
  """
  @spec document_path(binary | Path.t()) :: Path.t() | nil
  def document_path(name_or_path) do
    if File.exists?(name_or_path) do
      name_or_path
    else
      Index.get_document_path(name_or_path)
    end
  end

  @doc """
  Determines the type of the document with the given `name_or_path`.

  The type is determined by the `magma_type` property within the document's
  YAML front matter.
  """
  @spec document_type(binary | Path.t()) :: {:ok, Document.type()} | {:error, any}
  def document_type(name_or_path) do
    if path = document_path(name_or_path) do
      with {:ok, metadata, _body} <- YamlFrontMatter.parse_file(path) do
        magma_type = metadata["magma_type"]

        if document_type = Document.type(magma_type) do
          {:ok, document_type}
        else
          {:error, "invalid magma_type in #{path}: #{inspect(magma_type)}"}
        end
      end
    else
      {:error, Magma.DocumentNotFound.exception(name: name_or_path)}
    end
  end
end

```

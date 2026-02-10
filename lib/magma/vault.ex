defmodule Magma.Vault do
  @moduledoc """
  A specialized Obsidian vault with directories for the Magma-specific documents.

  The `Magma.Vault` module serves as a representation and utility module for a Magma vault - a specialized Obsidian vault that houses Magma documents, which are special kinds of Markdown documents with specific paths and purposes. The vault itself can be stored by default in the `magma/` directory of a project but can be reconfigured as needed (see `path/0`).

  Main functions of this module include:

  - Retrieving paths within the vault, like the base path, template paths, etc.
  - Creating and initializing a new vault (`create/2`).
  - Indexing documents by name (`index/1`).
  - Fetching details of documents, such as their path (`document_path/1`) or type (`document_type/1`).

  """

  alias Magma.Document
  alias Magma.Vault.Index

  import Magma.Utils, only: [file_format_timestamp: 1]

  @default_path "magma"
  @template_path_prefix "templates"
  @custom_prompt_template_name "custom_prompt.md"
  @session_template_name "session.md"
  @session_continuation_template_name "session_continuation.md"

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
      # returns: "/path/to/project/magma/directory"

      Magma.Vault.path(["some", "directory"])
      # returns: "/path/to/project/magma/some/directory"

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
      # returns: "/path/to/project/magma/templates/some_template.md"

  """
  @spec template_path(binary | [binary]) :: Path.t()
  def template_path(segments), do: Path.join([template_path() | List.wrap(segments)])

  @doc """
  Returns the Vault path for the custom prompt template.
  """
  @spec custom_prompt_template_path :: Path.t()
  def custom_prompt_template_path, do: template_path(@custom_prompt_template_name)

  @doc """
  Returns the Vault path for the Session template.
  """
  @spec session_template_path :: Path.t()
  def session_template_path, do: template_path(@session_template_name)

  @doc """
  Returns the Vault path for the Session continuation template.
  """
  @spec session_continuation_template_path :: Path.t()
  def session_continuation_template_path,
    do: template_path(@session_continuation_template_name)

  @doc """
  Returns the Vault path for the Session response prompt EEx template.
  """
  @spec session_response_prompt_template_path :: Path.t()
  def session_response_prompt_template_path do
    Magma.Config.path(["templates", "session_response_prompt.eex.md"])
  end

  @doc """
  Returns the Vault path for the Session response files directory.
  """
  @spec session_response_directory :: Path.t()
  def session_response_directory, do: path([Magma.Session.path_prefix(), ".responses"])

  @doc """
  Generates a timestamped response file path for a session.
  """
  @spec session_response_file_path(String.t(), DateTime.t() | binary) :: Path.t()
  def session_response_file_path(session_name, timestamp \\ DateTime.utc_now())

  def session_response_file_path(session_name, timestamp) when is_binary(timestamp) do
    Path.join(session_response_directory(), "#{session_name}.response_#{timestamp}.md")
  end

  def session_response_file_path(session_name, timestamp) do
    session_response_file_path(session_name, file_format_timestamp(timestamp))
  end

  @doc """
  Creates and initializes a new vault.

  The `base_vault` specifies the `Magma.Vault.BaseVault` to be used for
  initializing the new Magma vault. It can be specified with any of arguments
  accepted by `Magma.Vault.BaseVault.path/1`.

  Available `opts`:

  - `:force` (default: `false`): allow to force creation even if a vault already exists


  Returns `:ok` if the vault is successfully created or an error tuple if
  there's an error during the vault creation process.
  """
  @spec create(base_vault :: Magma.Vault.BaseVault.theme() | Path.t() | nil, keyword) ::
          :ok | {:error, any}
  defdelegate create(base_vault \\ nil, opts \\ []),
    to: Magma.Vault.Initializer,
    as: :initialize

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

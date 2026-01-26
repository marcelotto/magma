defmodule Magma.Session do
  use Magma.Document, fields: [:parts, :response_mode]

  @type response_mode :: :disabled | :enabled | :import

  @type t :: %__MODULE__{
          parts: Magma.Session.Parser.parts(),
          response_mode: response_mode() | nil
        }

  alias Magma.Vault
  alias Magma.Session.{Parser, Template}

  @path_prefix "sessions"
  def path_prefix, do: @path_prefix

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{name: name}) do
    {:ok, [@path_prefix, name <> ".md"] |> Vault.path()}
  end

  def new(name, attrs \\ []) do
    struct(__MODULE__, Keyword.put(attrs, :name, name))
    |> Document.init_path()
  end

  def new!(name, attrs \\ []) do
    case new(name, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(name, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document
    |> Document.init()
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Session.create/3 is available only with an initialized document"
      )

  def create(name, attrs, opts) do
    with {:ok, document} <- new(name, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{response_mode: response_mode}) do
    """
    session_response_mode: #{response_mode && to_string(response_mode)}
    """
    |> String.trim_trailing()
  end

  def render(%__MODULE__{} = session) do
    %__MODULE__{session | content: Template.render(session)}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = session) do
    {response_mode, metadata} = Map.pop(session.custom_metadata, :session_response_mode)

    with {:ok, parts} <- Parser.parse(session.content) do
      {:ok,
       %__MODULE__{
         session
         | parts: parts,
           response_mode: response_mode && String.to_atom(response_mode),
           custom_metadata: metadata
       }}
    end
  end

  @doc """
  Detects the session mode based on the presence of Prompt separators.

  Returns `:initial` if no `***Prompt***` separators are found (initial mode).
  Returns `:continuation` if `***Prompt***` separators are present (continuation mode).
  """
  @spec mode(t()) :: :initial | :continuation
  def mode(%__MODULE__{parts: parts}) do
    if Enum.any?(parts, fn {type, _} -> type == :prompt end) do
      :continuation
    else
      :initial
    end
  end

  @doc """
  Returns the session_response_mode for this session.

  Checks the session's `response_mode` field first, falling back to system config.
  """
  @spec response_mode(t()) :: response_mode()
  def response_mode(%__MODULE__{response_mode: nil}),
    do: Magma.Config.system(:session_response_mode)

  def response_mode(%__MODULE__{response_mode: mode}), do: mode

  @doc """
  Extracts the AST nodes of the last Prompt section.

  Returns the AST nodes if in continuation mode.
  Returns `nil` if in initial mode (no Prompt sections found).
  """
  @spec last_prompt_part(t()) :: [Panpipe.AST.Node.t()] | nil
  def last_prompt_part(%__MODULE__{parts: parts}) do
    parts
    |> Enum.reverse()
    |> Enum.find_value(fn
      {:prompt, content} -> content
      _ -> nil
    end)
  end

  @doc """
  Imports a response from an external file into the session document.

  Finds the latest response file for the session, reads its content,
  replaces the import button with the response content, and deletes the response file.
  """
  @spec import_response(String.t() | t()) :: {:ok, t()} | {:error, any}
  def import_response(session_name) when is_binary(session_name) do
    with {:ok, session} <- load(session_name) do
      import_response(session)
    end
  end

  def import_response(%__MODULE__{} = session) do
    with {:ok, response_file} <- find_latest_session_response(session),
         {:ok, response_content} <- read_response_file(response_file),
         {:ok, updated_session} <- replace_button_with_response(session, response_content),
         {:ok, _} <- Document.save(updated_session),
         :ok <- File.rm(response_file) do
      {:ok, updated_session}
    end
  end

  defp read_response_file(path) do
    case File.read(path) do
      {:ok, ""} -> {:error, "Response file is empty: #{path}"}
      {:ok, content} -> {:ok, String.trim(content)}
      {:error, reason} -> {:error, "Failed to read response file: #{inspect(reason)}"}
    end
  end

  defp replace_button_with_response(%__MODULE__{} = session, response) do
    case String.split(session.content, Template.import_response_button()) do
      [before, after_] -> {:ok, %__MODULE__{session | content: before <> response <> after_}}
      [_] -> {:error, "No import button found in session document"}
      _multiple -> {:error, "Multiple import buttons found in session document"}
    end
  end

  @doc """
  Finds the latest response file for a given session.

  Returns `{:ok, path}` if found, `{:error, :not_found}` if no response files exist.
  """
  @spec find_latest_session_response(t()) :: {:ok, Path.t()} | {:error, :not_found}
  def find_latest_session_response(%__MODULE__{} = session) do
    pattern = Path.join(Vault.session_response_directory(), "#{session.name}.response_*.md")

    case Path.wildcard(pattern) do
      [] -> {:error, :not_found}
      files -> {:ok, Enum.max(files)}
    end
  end
end

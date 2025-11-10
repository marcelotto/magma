defmodule Magma.Session do
  use Magma.Document, fields: [:parts]

  @type t :: %__MODULE__{
          parts: Magma.Session.Parser.parts()
        }

  alias Magma.Vault
  alias Magma.Prompt.Template
  alias Magma.Session.Parser

  @path_prefix "sessions"
  def path_prefix, do: @path_prefix

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{name: name}) do
    {:ok, [@path_prefix, name <> ".md"] |> Vault.path()}
  end

  @impl true
  def from(%__MODULE__{} = session), do: session

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
  def render_front_matter(_), do: nil

  def render(%__MODULE__{} = session) do
    %__MODULE__{session | content: Template.render(session, Magma.Config.project())}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = session) do
    with {:ok, parts} <- Parser.parse(session.content) do
      {:ok, %__MODULE__{session | parts: parts}}
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
end

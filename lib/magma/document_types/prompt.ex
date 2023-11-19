defmodule Magma.Prompt do
  use Magma.Document, fields: [:generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Generation, PromptResult}
  alias Magma.Matter.Project
  alias Magma.Prompt.Template

  @path_prefix "custom_prompts"
  def path_prefix, do: @path_prefix

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{name: name}) do
    {:ok, [@path_prefix, name <> ".md"] |> Vault.path()}
  end

  @impl true
  def from(%__MODULE__{} = prompt), do: prompt
  def from(%PromptResult{prompt: %__MODULE__{}} = result), do: result.prompt

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
    |> Document.init(generation: Generation.default().new!())
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(ArgumentError, "Magma.Prompt.create/3 is available only with an initialized document")

  def create(name, attrs, opts) do
    with {:ok, document} <- new(name, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%{generation: generation}) do
    Generation.render_front_matter(generation)
  end

  def render(%__MODULE__{} = prompt) do
    %__MODULE__{prompt | content: Template.render(prompt, Project.concept())}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt) do
    with {:ok, generation, metadata} <- Generation.extract_from_metadata(prompt.custom_metadata) do
      {:ok,
       %__MODULE__{
         prompt
         | generation: generation,
           custom_metadata: metadata
       }}
    end
  end
end

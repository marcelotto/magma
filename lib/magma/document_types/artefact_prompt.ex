defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Matter, Generation, Prompt, PromptResult}
  alias Magma.Prompt.Template

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{artefact: artefact}) do
    {:ok, artefact |> Artefact.relative_prompt_path() |> Vault.artefact_generation_path()}
  end

  @impl true
  def from(%__MODULE__{} = prompt), do: prompt
  def from(%PromptResult{prompt: %__MODULE__{}} = result), do: result.prompt
  def from(%Artefact.Version{} = version), do: from(version.draft)
  def from(%_artefact_type{concept: _, name: _} = artefact), do: new!(artefact).name

  def new(%_artefact_type{concept: _, name: _} = artefact, attrs \\ []) do
    __MODULE__
    |> struct(Keyword.put(attrs, :artefact, artefact))
    |> Document.init_path()
  end

  def new!(artefact, attrs \\ []) do
    case new(artefact, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(prompt_or_artefact, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document
    |> Document.init(generation: Generation.default())
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Prompt.create/3 is not available with an initialized document"
      )

  def create(artefact, attrs, opts) do
    with {:ok, document} <- new(artefact, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    #{Artefact.render_front_matter(document.artefact)}
    #{Prompt.render_front_matter(document)}
    """
    |> String.trim_trailing()
  end

  def render(%__MODULE__{} = prompt) do
    %__MODULE__{prompt | content: Template.render(prompt, Matter.Project.concept())}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt) do
    with {:ok, artefact, metadata} <- Artefact.extract_from_metadata(prompt.custom_metadata),
         {:ok, generation, metadata} <- Generation.extract_from_metadata(metadata) do
      {:ok,
       %__MODULE__{
         prompt
         | artefact: artefact,
           generation: generation,
           custom_metadata: metadata
       }}
    end
  end
end

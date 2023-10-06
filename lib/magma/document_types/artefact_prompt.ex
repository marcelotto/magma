defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact, :concept, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, Matter, Generation, Prompt, PromptResult, View}
  alias Magma.Prompt.Template

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    {:ok, concept |> artefact.relative_prompt_path() |> Vault.artefact_generation_path()}
  end

  @impl true
  def from(%__MODULE__{} = prompt), do: prompt
  def from({%Concept{} = concept, artefact}), do: artefact.prompt!(concept).name
  def from(%PromptResult{prompt: %__MODULE__{}} = result), do: result.prompt
  def from(%Artefact.Version{} = version), do: from(version.draft)

  def new(concept, artefact, attrs \\ []) do
    struct(__MODULE__, [{:artefact, artefact}, {:concept, concept} | attrs])
    |> Document.init_path()
  end

  def new!(concept, artefact, attrs \\ []) do
    case new(concept, artefact, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(concept, artefact, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, [], []) do
    document
    |> Document.init(generation: Generation.default().new!())
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Prompt.create/4 is available only with an initialized document"
      )

  def create(concept, artefact, attrs, opts) do
    with {:ok, document} <- new(concept, artefact, attrs) do
      create(document, opts)
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    magma_artefact: #{Artefact.type_name(document.artefact)}
    magma_concept: "#{View.link_to(document.concept)}"
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
    {artefact_type, metadata} = Map.pop(prompt.custom_metadata, :magma_artefact)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)

    cond do
      !artefact_type ->
        {:error, "artefact_type missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, concept} <- Concept.load_linked(concept_link),
             {:ok, generation, metadata} <- Generation.extract_from_metadata(metadata) do
          {:ok,
           %__MODULE__{
             prompt
             | artefact: artefact_module,
               concept: concept,
               generation: generation,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

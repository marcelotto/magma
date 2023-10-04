defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:artefact, :concept, :draft]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, PromptResult, DocumentStruct}
  alias Magma.DocumentStruct.Section
  alias Magma.Document.Loader
  alias Magma.Text.Preview

  @impl true
  def title(%__MODULE__{name: name}), do: name

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    build_path(concept, artefact)
  end

  def build_path(concept, artefact) do
    {:ok, concept |> artefact.relative_version_path() |> Vault.artefact_version_path()}
  end

  @impl true
  def from(%__MODULE__{} = version), do: version
  def from({%Concept{} = concept, artefact}), do: artefact.name(concept)

  def from(%Artefact.Prompt{} = prompt),
    do: from({Concept.from(prompt), prompt.artefact})

  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result),
    do: from({Concept.from(result), result.prompt.artefact})

  def new(draft, attrs \\ [])

  def new(%PromptResult{prompt: %Artefact.Prompt{}} = prompt_result, attrs) do
    attrs =
      attrs
      |> Keyword.put_new(:concept, prompt_result.prompt.concept)
      |> Keyword.put_new(:artefact, prompt_result.prompt.artefact)

    cond do
      attrs[:concept] != prompt_result.prompt.concept -> {:error, "inconsistent concept"}
      attrs[:artefact] != prompt_result.prompt.artefact -> {:error, "inconsistent artefact"}
      true -> do_new(prompt_result, attrs)
    end
  end

  def new(%Preview{} = preview, attrs) do
    attrs =
      attrs
      |> Keyword.put_new(:concept, preview.concept)
      |> Keyword.put_new(:artefact, preview.artefact)

    cond do
      attrs[:concept] != preview.concept -> {:error, "inconsistent concept"}
      attrs[:artefact] != preview.artefact -> {:error, "inconsistent artefact"}
      true -> do_new(preview, attrs)
    end
  end

  def new(%Magma.DocumentNotFound{} = missing_document, attrs) do
    cond do
      !attrs[:concept] -> {:error, "concept missing"}
      !attrs[:artefact] -> {:error, "artefact missing"}
      true -> do_new(missing_document, attrs)
    end
  end

  defp do_new(draft, attrs) do
    struct(__MODULE__, [{:draft, draft} | attrs])
    |> Document.init_path()
  end

  def new!(draft, attrs \\ []) do
    case new(draft, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(draft, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init()
           |> assemble() do
      Document.create(document, opts)
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Version.create/3 is available only with new/2 arguments"
      )

  def create(draft, attrs, opts) do
    with {:ok, document} <- new(draft, attrs) do
      create(document, opts)
    end
  end

  defp assemble(%__MODULE__{draft: %PromptResult{}} = document) do
    content =
      """
      # #{title(document)}

      #{Document.content_without_prologue(document.draft)}
      """

    {:ok, %__MODULE__{document | content: prologue(document) <> content}}
  end

  defp assemble(%__MODULE__{draft: %Preview{}} = document) do
    with {:ok, document_struct} <- DocumentStruct.parse(document.draft.content) do
      content =
        document_struct
        |> DocumentStruct.main_section()
        |> Section.resolve_transclusions()
        |> Section.remove_comments()
        |> Section.to_string()

      {:ok, %__MODULE__{document | content: prologue(document) <> content}}
    end
  end

  defp prologue(%__MODULE__{artefact: artefact} = version) do
    if prologue = artefact.version_prologue(version) do
      """

      #{prologue}

      """
    else
      ""
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    import Magma.Obsidian.View.Helper

    """
    magma_artefact: #{Magma.Artefact.type_name(document.artefact)}
    magma_concept: "#{link_to(document.concept)}"
    magma_draft: "#{link_to(document.draft)}"
    """
    |> String.trim_trailing()
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = version) do
    {draft_link, metadata} = Map.pop(version.custom_metadata, :magma_draft)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)
    {artefact_type, metadata} = Map.pop(metadata, :magma_artefact)

    cond do
      !draft_link ->
        {:error, "magma_draft missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      !artefact_type ->
        {:error, "magma_artefact missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, draft} <-
               (case Loader.load_linked([PromptResult, Preview], draft_link) do
                  {:ok, _} = ok -> ok
                  {:error, %Magma.DocumentNotFound{} = e} -> {:ok, e}
                end),
             {:ok, concept} <- Concept.load_linked(concept_link) do
          {:ok,
           %__MODULE__{
             version
             | artefact: artefact_module,
               concept: concept,
               draft: draft,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

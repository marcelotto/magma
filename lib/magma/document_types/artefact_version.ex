defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:artefact, :concept, :prompt_result]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept}

  def build_name(concept, artefact) do
    artefact.name(concept)
  end

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    build_path(concept, artefact)
  end

  def build_path(concept, artefact) do
    {:ok, concept |> artefact.relative_version_path() |> Vault.artefact_version_path()}
  end

  def new(prompt_result, attrs \\ [])

  def new(%Artefact.PromptResult{} = prompt_result, attrs) do
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

  def new(%Magma.DocumentNotFound{} = missing_prompt_result, attrs) do
    cond do
      !attrs[:concept] -> {:error, "concept missing"}
      !attrs[:artefact] -> {:error, "artefact missing"}
      true -> do_new(missing_prompt_result, attrs)
    end
  end

  defp do_new(prompt_result, attrs) do
    struct(__MODULE__, [{:prompt_result, prompt_result} | attrs])
    |> Document.init_path()
  end

  def new!(prompt_result, attrs \\ []) do
    case new(prompt_result, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(prompt, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document = Document.init(document)
    Document.create_file(document, render(document), opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Version.create/3 is available only with new/2 arguments"
      )

  def create(prompt_result, attrs, opts) do
    with {:ok, document} <- new(prompt_result, attrs) do
      create(document, opts)
    end
  end

  defp render(document) do
    import Magma.Obsidian.View.Helper

    """
    ---
    magma_type: Artefact.Version
    magma_artefact: #{Magma.Artefact.type_name(document.artefact)}
    magma_concept: "#{link_to(document.concept)}"
    magma_prompt_result: "#{link_to(document.prompt_result)}"
    created_at: #{document.created_at}
    tags: #{yaml_list(document.tags)}
    aliases: #{yaml_list(document.aliases)}
    ---
    #{Document.content_without_prologue(document.prompt_result)}
    """
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = version) do
    {prompt_result_link, metadata} = Map.pop(version.custom_metadata, :magma_prompt_result)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)
    {artefact_type, metadata} = Map.pop(metadata, :magma_artefact)

    cond do
      !prompt_result_link ->
        {:error, "magma_prompt_result missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      !artefact_type ->
        {:error, "magma_artefact missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, prompt_result} <-
               (case Artefact.PromptResult.load_linked(prompt_result_link) do
                  {:ok, _} = ok ->
                    ok

                  {:error, %Magma.DocumentNotFound{} = missing_prompt_result} ->
                    {:ok, missing_prompt_result}
                end),
             {:ok, concept} <- Concept.load_linked(concept_link) do
          {:ok,
           %__MODULE__{
             version
             | artefact: artefact_module,
               concept: concept,
               prompt_result: prompt_result,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

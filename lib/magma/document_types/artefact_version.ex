defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:prompt_result]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Utils}

  def build_name(concept, artefact) do
    artefact.build_name(concept)
  end

  @impl true
  def build_path(%__MODULE__{
        prompt_result: %Artefact.PromptResult{
          prompt: %Artefact.Prompt{artefact: artefact, concept: concept}
        }
      }) do
    build_path(concept, artefact)
  end

  def build_path(concept, artefact) do
    {:ok, concept |> artefact.build_version_path() |> Vault.artefact_version_path()}
  end

  def new(prompt_result, attrs \\ []) do
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
    {prompt_result_link, custom_metadata} = Map.pop(version.custom_metadata, :magma_prompt_result)

    if prompt_result_link do
      prompt_result_link
      |> Utils.extract_link_text()
      |> Vault.document_path()
      |> case do
        nil ->
          {:error, "invalid magma_prompt_result link: #{prompt_result_link}"}

        document_path ->
          with {:ok, prompt_result} <- Artefact.PromptResult.load(document_path) do
            {:ok,
             %__MODULE__{
               version
               | prompt_result: prompt_result,
                 custom_metadata: custom_metadata
             }}
          end
      end
    else
      {:error, "magma_prompt_result missing"}
    end
  end
end

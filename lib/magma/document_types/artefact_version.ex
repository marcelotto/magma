defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:prompt_result]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Utils}

  def build_name(%artefact_type{concept: concept}) do
    artefact_type.build_name(concept)
  end

  @impl true
  def build_path(%__MODULE__{
        prompt_result: %Artefact.PromptResult{
          prompt: %Artefact.Prompt{artefact: artefact}
        }
      }) do
    build_path(artefact)
  end

  def build_path(%artefact_type{} = artefact) do
    {:ok, artefact |> artefact_type.build_version_path() |> Vault.artefact_version_path()}
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
    with {:ok, document} <-
           document
           |> Document.init()
           |> Document.create_file_from_template(opts) do
      Document.Loader.load(document)
    end
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

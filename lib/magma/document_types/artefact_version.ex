defmodule Magma.Artefact.Version do
  use Magma.Document, fields: [:prompt_result]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Utils}

  @impl true
  def dependency, do: :prompt_result

  def build_name(%artefact_type{concept: concept}) do
    artefact_type.build_name(concept)
  end

  @impl true
  def build_path(%__MODULE__{
        prompt_result: %Artefact.PromptResult{
          prompt: %Artefact.Prompt{artefact: %artefact_type{} = artefact}
        }
      }) do
    {:ok, artefact |> artefact_type.version_path() |> Vault.artefact_path()}
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

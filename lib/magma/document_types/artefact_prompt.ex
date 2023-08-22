defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefacts, Concept, Utils}

  @impl true
  def dependency, do: :artefact

  @impl true
  def build_path(%__MODULE__{artefact: %artefact_type{} = artefact}) do
    {:ok, artefact |> artefact_type.prompt_path() |> Vault.artefact_path()}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt) do
    {artefact_type, custom_metadata} = Map.pop(prompt.custom_metadata, :magma_artefact)
    {concept_link, custom_metadata} = Map.pop(custom_metadata, :magma_concept)

    cond do
      !artefact_type ->
        {:error, "artefact_type missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      true ->
        artefact_module = Module.concat(Artefacts, artefact_type)

        concept_link
        |> Utils.extract_link_text()
        |> Vault.document_path()
        |> case do
          nil ->
            {:error, "invalid magma_concept link: #{concept_link}"}

          document_path ->
            with {:ok, concept} <- Concept.load(document_path),
                 {:ok, artefact} <- artefact_module.new(concept) do
              {:ok,
               %__MODULE__{
                 prompt
                 | artefact: artefact,
                   custom_metadata: custom_metadata
               }}
            end
        end
    end
  end
end

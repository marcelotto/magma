defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, Utils}
  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section

  require Logger

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

      artefact_module = Artefact.type(artefact_type) ->
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

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end

  def messages(%__MODULE__{} = prompt) do
    with {:ok, document_struct} <- DocumentStruct.parse(prompt.content) do
      case document_struct.sections do
        [
          %{
            sections: [
              %Section{title: "Setup"} = setup_section,
              %Section{title: "Request"} = request_section
              | more_subsections
            ]
          }
          | more_sections
        ] ->
          unless Enum.empty?(more_sections) && Enum.empty?(more_subsections) do
            Logger.warning(
              "#{prompt.name} contains subsections which won't be taken into account. Put them under the request section if you want that."
            )
          end

          {
            :ok,
            Section.to_string(setup_section, header: false),
            Section.to_string(request_section, header: false)
          }
      end
    end
  end
end

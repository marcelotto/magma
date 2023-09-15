defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact, :concept]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, Utils}
  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section
  alias Magma.Artefact.Prompt.Template

  require Logger

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    {:ok, concept |> artefact.build_prompt_path() |> Vault.artefact_generation_path()}
  end

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
    document = Document.init(document)
    Document.create_file(document, Template.render(document), opts)
  end

  def create(%__MODULE__{}, _, _, []),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.Prompt.create/4 is available only with new/2 arguments"
      )

  def create(concept, artefact, attrs, opts) do
    with {:ok, document} <- new(concept, artefact, attrs) do
      create(document, opts)
    end
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
            with {:ok, concept} <- Concept.load(document_path) do
              {:ok,
               %__MODULE__{
                 prompt
                 | artefact: artefact_module,
                   concept: concept,
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
              %Section{title: "System prompt"} = system_prompt_section,
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
            to_message_string(system_prompt_section),
            to_message_string(request_section)
          }
      end
    end
  end

  defp to_message_string(section) do
    section
    |> Section.resolve_transclusions()
    |> Section.remove_comments()
    |> Section.to_string(header: false)
  end
end

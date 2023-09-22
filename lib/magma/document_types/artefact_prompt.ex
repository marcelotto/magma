defmodule Magma.Artefact.Prompt do
  use Magma.Document, fields: [:artefact, :concept, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, Matter, Generation}
  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section
  alias Magma.Artefact.Prompt.Template

  require Logger

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title
  @request_prompt_section_title "Request"
  def request_prompt_section_title, do: @request_prompt_section_title

  @impl true
  def build_path(%__MODULE__{artefact: artefact, concept: concept}) do
    {:ok, concept |> artefact.relative_prompt_path() |> Vault.artefact_generation_path()}
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
    document
    |> Document.init(generation: Generation.default().new!())
    |> render()
    |> Document.save(opts)
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
  def render_front_matter(%__MODULE__{} = document) do
    import Magma.Obsidian.View.Helper

    """
    magma_artefact: #{Magma.Artefact.type_name(document.artefact)}
    magma_concept: "#{link_to(document.concept)}"
    magma_generation_type: #{inspect(Magma.Generation.short_name(document.generation))}
    magma_generation_params: #{yaml_nested_map(document.generation)}
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

  def messages(%__MODULE__{} = prompt) do
    with {:ok, document_struct} <- DocumentStruct.parse(prompt.content) do
      case document_struct.sections do
        [
          %{
            sections: [
              %Section{title: @system_prompt_section_title} = system_prompt_section,
              %Section{title: @request_prompt_section_title} = request_section
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

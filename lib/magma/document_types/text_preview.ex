defmodule Magma.Text.Preview do
  use Magma.Document, fields: [:artefact, :concept]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Concept, Matter, Artefact}
  alias Magma.Obsidian.View

  import Magma.Utils, only: [map_while_ok: 2]

  require Logger

  @impl true
  def title(%__MODULE__{} = preview), do: build_name(preview)

  def build_name(%__MODULE__{} = preview) do
    build_name(preview.artefact, preview.concept)
  end

  def build_name(artefact, %Concept{} = concept) do
    "#{artefact.name(concept)} preview"
  end

  @impl true
  def build_path(%__MODULE__{concept: text_concept} = preview) do
    {:ok,
     [
       Matter.Text.relative_base_path(text_concept.subject),
       "__previews__",
       "#{title(preview)}.md"
     ]
     |> Vault.artefact_generation_path()}
  end

  def new(%Concept{subject: %Matter.Text{}} = concept, artefact, attrs \\ []) do
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
    with {:ok, document} <-
           document
           |> Document.init()
           |> render(),
         {:ok, document} <- Document.create(document, opts) do
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _, []),
    do:
      raise(
        ArgumentError,
        "Magma.Preview.create/4 is available only with new/2 arguments"
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
    magma_concept: "#{View.Helper.link_to(document.concept)}"
    """
    |> String.trim_trailing()
  end

  def render(%__MODULE__{} = preview) do
    with {:ok, content} <- render_from_toc(preview) do
      {:ok, %__MODULE__{preview | content: content}}
    end
  end

  defp render_from_toc(preview) do
    if section = preview.concept[Matter.Text.sections_section_title()] do
      with {:ok, toc} <-
             section
             |> extract_concept_toc()
             |> map_while_ok(&version_section_transclusion(preview, &1)) do
        {
          :ok,
          """
          # #{title(preview)}

          #{Enum.join(toc, "\n\n")}
          """
        }
      end
    else
      {:error, "No 'Sections' section found in #{preview.concept.path}"}
    end
  end

  defp extract_concept_toc(section) do
    Enum.flat_map(section.sections, fn
      %Magma.DocumentStruct.Section{
        header: %Panpipe.AST.Header{
          children: [
            %Panpipe.AST.Link{},
            %Panpipe.AST.Space{},
            %Panpipe.AST.Image{target: target, title: "wikilink"}
          ]
        }
      } ->
        case String.split(target, "#", parts: 2) do
          [concept_name, _] -> [concept_name]
          [concept_name] -> [concept_name]
        end

      _ ->
        []
    end)
  end

  defp version_section_transclusion(preview, concept_name) do
    with {:ok, concept} <- Concept.load(concept_name) do
      version_name = preview.artefact.name(concept)
      {:ok, "## #{Concept.title(concept)} ![[#{version_name}##{version_name}]]"}
    end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = preview) do
    {artefact_type, metadata} = Map.pop(preview.custom_metadata, :magma_artefact)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)

    cond do
      !artefact_type ->
        {:error, "artefact_type missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      artefact_module = Artefact.type(artefact_type) ->
        with {:ok, concept} <- Concept.load_linked(concept_link) do
          {:ok,
           %__MODULE__{
             preview
             | artefact: artefact_module,
               concept: concept,
               custom_metadata: metadata
           }}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type}"}
    end
  end
end

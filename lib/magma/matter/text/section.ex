defmodule Magma.Matter.Text.Section do
  use Magma.Matter, fields: [:main_text]

  alias Magma.{Concept, Artefact}
  alias Magma.Matter.Text
  alias Magma.Artefacts.TableOfContents
  alias Magma.Obsidian.View

  require Logger

  @type t :: %__MODULE__{}

  @impl true
  def artefacts, do: [Magma.Artefacts.Article]

  @impl true
  def relative_base_path(%__MODULE__{main_text: main_text}) do
    Text.relative_base_path(main_text)
  end

  @impl true
  def relative_concept_path(%__MODULE__{} = section) do
    section
    |> relative_base_path()
    |> Path.join("#{concept_name(section)}.md")
  end

  @impl true
  def concept_name(%__MODULE__{name: name, main_text: main_text}) do
    "#{main_text.name} - #{name}"
  end

  @impl true
  def concept_title(%__MODULE__{name: name}), do: name

  @impl true
  def default_description(%__MODULE__{}, abstract: abstract), do: abstract

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{main_text: main_text}}) do
    """
    #### Outline of the '#{main_text.name}' content #{View.Helper.transclude(TableOfContents.name(main_text), :title)}

    """ <>
      case Concept.load(main_text.name) do
        {:ok, text_concept} ->
          Artefact.Prompt.Template.include_context_knowledge(text_concept)

        {:error, error} ->
          Logger.warning("error on main text context knowledge extraction: #{inspect(error)}")
          ""
      end
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the intended content of the '#{name}' section"
  end

  @impl true
  def new(attrs) when is_list(attrs) do
    {:ok, struct(__MODULE__, attrs)}
  end

  def new(main_text, name) do
    new(name: name, main_text: main_text)
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  def new!(main_text, name) do
    case new(main_text, name) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(_document_name, document_title, metadata) do
    {main_text_link, metadata} = Map.pop(metadata, :magma_section_of)

    if main_text_link do
      with {:ok, main_text_concept} <- Concept.load_linked(main_text_link),
           {:ok, matter} <- new(main_text_concept.subject, document_title) do
        {:ok, matter, metadata}
      end
    else
      {:error, "magma_section_of missing"}
    end
  end

  def render_front_matter(%__MODULE__{} = section) do
    """
    #{super(section)}
    magma_section_of: "#{View.Helper.link_to(section.main_text)}"
    """
    |> String.trim_trailing()
  end
end

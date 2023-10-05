defmodule Magma.Concept do
  use Magma.Document,
    fields: [
      # the thing the concept is about
      :subject,
      # the content of the first level 1 header
      :title,
      # AST of the text before the title header
      :prologue,
      # ASTs of the sections
      :sections
    ]

  alias Magma.{Vault, Matter, DocumentStruct, Artefact, PromptResult}
  alias Magma.Concept.Template

  @type t :: %__MODULE__{}

  @description_section_title "Description"
  def description_section_title, do: @description_section_title

  @context_knowledge_section_title "Context knowledge"
  def context_knowledge_section_title, do: @context_knowledge_section_title

  @impl true
  def title(%__MODULE__{subject: %matter_type{} = matter}) do
    matter_type.concept_title(matter)
  end

  @impl true
  def build_path(%__MODULE__{subject: matter}), do: build_path(matter)

  def build_path(%matter_type{} = matter) do
    {:ok, matter |> matter_type.relative_concept_path() |> Vault.concept_path()}
  end

  @impl true
  def from(%__MODULE__{} = concept), do: concept
  def from(%Artefact.Prompt{} = prompt), do: prompt.concept
  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result), do: result.prompt.concept
  def from(%Artefact.Version{} = version), do: version.concept

  def new(subject, attrs \\ []) do
    struct(__MODULE__, [{:subject, subject} | attrs])
    |> Document.init_path()
  end

  def new!(subject, attrs \\ []) do
    case new(subject, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(subject, attrs \\ [], opts \\ [])

  def create(%__MODULE__{subject: %matter_type{} = matter} = document, opts, []) do
    {assigns, opts} = Keyword.pop(opts, :assigns, [])

    with {:ok, document} <-
           document
           |> Document.init(aliases: matter_type.default_concept_aliases(matter))
           |> render(assigns) do
      Document.create(document, opts)
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Concept.create/3 is available only with an initialized document"
      )

  def create(subject, attrs, opts) do
    with {:ok, document} <- new(subject, attrs) do
      create(document, opts)
    end
  end

  def create!(subject, attrs \\ [], opts \\ []) do
    case create(subject, attrs, opts) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  @impl true
  def render_front_matter(%__MODULE__{subject: %matter_type{} = matter}) do
    matter_type.render_front_matter(matter)
  end

  def render(%__MODULE__{} = concept, assigns) do
    %__MODULE__{concept | content: Template.render(concept, assigns)}
    |> parse()
  end

  defp parse(concept) do
    with {:ok, document_struct} <- DocumentStruct.parse(concept.content) do
      {:ok,
       %__MODULE__{
         concept
         | title: DocumentStruct.title(document_struct),
           prologue: document_struct.prologue,
           sections: document_struct.sections
       }}
    end
  end

  def update_content_from_ast(%__MODULE__{} = concept) do
    %__MODULE__{concept | content: DocumentStruct.to_string(concept)}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = concept) do
    with {:ok, concept} <- parse(concept),
         {:ok, matter, custom_metadata} <-
           Matter.extract_from_metadata(concept.name, concept.title, concept.custom_metadata) do
      {:ok, %__MODULE__{concept | subject: matter, custom_metadata: custom_metadata}}
    end
  end

  defdelegate fetch(concept, key), to: DocumentStruct

  def description_section(%__MODULE__{} = concept),
    do: get_in(concept, [concept.title, @description_section_title])

  def context_knowledge_section(%__MODULE__{} = concept),
    do: concept[@context_knowledge_section_title]
end

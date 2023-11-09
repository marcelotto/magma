defmodule Magma.Concept do
  @moduledoc """
  The basic Magma document type used for generating concrete artefacts.

  It contains all user-contributed content necessary for artefact generation,
  such as descriptions of the subject matter, background knowledge, and task
  descriptions for various artefacts.

  This module provides functions for creating, loading and updating these
  concept documents, as well as functions for accessing specific sections
  of the document such as the description and context knowledge sections.
  It also allows for the creation of prompts based on a concept.
  """

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

  import Magma.Utils

  @type t :: %__MODULE__{}

  @default_artefacts :all

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
  def from(%Artefact.Prompt{} = prompt), do: prompt.artefact.concept
  def from(%PromptResult{prompt: %Artefact.Prompt{}} = result), do: result.prompt.artefact.concept
  def from(%Artefact.Version{} = version), do: version.artefact.concept

  @doc """
  Creates a new concept document struct for a given subject matter.

  Note, this function doesn't create the document in the `Magma.Vault`.
  Use `create/3` for this purpose.
  """
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

  @doc """
  Creates a new concept document for a given subject matter in the `Magma.Vault`.
  """
  def create(subject, attrs \\ [], opts \\ [])

  def create(%__MODULE__{subject: %matter_type{} = matter} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init(aliases: matter_type.default_concept_aliases(matter))
           |> render(opts),
         {:ok, document} <- Document.create(document, opts),
         {:ok, _prompts} <- create_prompts(document, opts) do
      {:ok, document}
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

  @doc """
  Creates a new concept document for a given subject matter in the `Magma.Vault`.

  Fails in error cases.
  """
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

  defp render(%__MODULE__{} = concept, opts) do
    with {:ok, artefact_types} <- artefacts(concept, opts) do
      assigns = Keyword.get(opts, :assigns, [])

      %__MODULE__{concept | content: Template.render(concept, artefact_types, assigns)}
      |> parse()
    end
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

  @spec update_content_from_ast(t()) :: t()
  def update_content_from_ast(%__MODULE__{} = concept) do
    %__MODULE__{concept | content: DocumentStruct.to_markdown(concept)}
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

  def create_prompts(%__MODULE__{} = concept, opts \\ []) do
    opts =
      if Keyword.has_key?(opts, :prompts) do
        Keyword.put(opts, :artefacts, Keyword.get(opts, :prompts))
      else
        opts
      end
      |> Keyword.put_new(:force, true)

    with {:ok, artefact_types} <- artefacts(concept, opts) do
      map_while_ok(artefact_types, fn artefact_type ->
        with {:ok, artefact} <- artefact_type.new(concept) do
          Artefact.Prompt.create(artefact, [], opts)
        end
      end)
    end
  end

  defp artefacts(%__MODULE__{subject: %matter_type{}}, opts) when is_list(opts) do
    artefacts(matter_type, Keyword.get(opts, :artefacts, @default_artefacts))
  end

  defp artefacts(matter_type, true), do: artefacts(matter_type, :all)
  defp artefacts(matter_type, false), do: artefacts(matter_type, [])
  defp artefacts(matter_type, nil), do: artefacts(matter_type, [])
  defp artefacts(matter_type, :all), do: {:ok, matter_type.artefacts()}

  defp artefacts(matter_type, artefacts) do
    compatible_artefact_types = matter_type.artefacts()

    artefacts
    |> List.wrap()
    |> map_while_ok(fn artefact_type ->
      cond do
        not Artefact.type?(artefact_type) ->
          {:error, "invalid artefact type: #{inspect(artefact_type)}"}

        artefact_type not in compatible_artefact_types ->
          {:error,
           "artefact type #{inspect(artefact_type)} is not compatible with matter type #{inspect(matter_type)}"}

        true ->
          {:ok, artefact_type}
      end
    end)
  end
end

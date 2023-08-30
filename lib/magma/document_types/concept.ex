defmodule Magma.Concept do
  alias Magma.{Vault, Matter, Artefact}
  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section

  use Magma.Document,
    fields: [
      # the thing the concept is about
      :subject,
      # the content of the first level 1 header
      :title,
      # text before the title header
      :prologue,
      # the "Description" section
      :subject_description,
      # the "Notes" section
      :subject_notes,
      # the "Artefacts" section
      :artefact_specs
    ]

  @type t :: %__MODULE__{}

  @impl true
  def dependency, do: :subject

  @impl true
  def build_path(%__MODULE__{subject: %matter_type{} = matter}) do
    {:ok, matter |> matter_type.concept_path() |> Vault.concept_path()}
  end

  @impl true
  def create_document(%__MODULE__{subject: %matter_type{} = matter} = concept) do
    if concept.aliases do
      {:ok, concept}
    else
      {:ok, struct(concept, aliases: matter_type.default_concept_aliases(matter))}
    end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = concept) do
    with {:ok, concept} <- load_front_matter_properties(concept),
         {:ok, document_struct} <- DocumentStruct.parse(concept.content) do
      interpret_document_struct(concept, document_struct)
    end
  end

  defp load_front_matter_properties(concept) do
    {matter_type, custom_metadata} = Map.pop(concept.custom_metadata, :magma_matter_type)
    {matter_name, custom_metadata} = Map.pop(custom_metadata, :magma_matter_name, concept.name)

    cond do
      !matter_type ->
        {:error, "magma_matter_type missing"}

      matter_module = Matter.type(matter_type) ->
        {:ok,
         %__MODULE__{
           concept
           | subject: matter_module.new(matter_name),
             custom_metadata: custom_metadata
         }}

      true ->
        {:error, "invalid magma_matter type: #{matter_type}"}
    end
  end

  defp interpret_document_struct(concept, document_struct) do
    with {:ok, title, description, notes} <- interpret_subject_section(document_struct.sections),
         {:ok, artefact_specs} <- interpret_artefacts_sections(document_struct.sections) do
      {:ok,
       %__MODULE__{
         concept
         | title: title,
           prologue: document_struct.prologue,
           subject_description: description,
           subject_notes: notes,
           artefact_specs: artefact_specs
       }}
    end
  end

  defp interpret_subject_section([
         {title, %Section{sections: [{"Description", description}, {"Notes", notes}]}}
         | _
       ]) do
    {:ok, title, description, notes}
  end

  defp interpret_subject_section([
         {title, %Section{sections: [{"Description", description}]}}
       ]) do
    {:ok, title, description, nil}
  end

  defp interpret_subject_section(_) do
    {:error, "invalid concept document: Description section missing"}
  end

  defp interpret_artefacts_sections([_, {"Artefacts", %Section{sections: artefacts_sections}} | _]) do
    {:ok, Enum.map(artefacts_sections, &interpret_artefacts_section/1)}
  end

  defp interpret_artefacts_sections(_) do
    {:ok, nil}
  end

  defp interpret_artefacts_section({"Commons", section}), do: {:commons, section}

  defp interpret_artefacts_section({artefact_type, section}) do
    {Artefact.type(artefact_type) || artefact_type, section}
  end
end

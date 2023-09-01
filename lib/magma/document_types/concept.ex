defmodule Magma.Concept do
  alias Magma.{Vault, Matter}
  alias Magma.DocumentStruct

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

  @type t :: %__MODULE__{}

  @description_section_title "Description"
  def description_section_title, do: @description_section_title
  @system_prompt_section_title "Artefact system prompts"
  def system_prompt_section_title, do: @system_prompt_section_title

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
    with {:ok, document_struct} <- DocumentStruct.parse(concept.content) do
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
               title: DocumentStruct.title(document_struct),
               prologue: document_struct.prologue,
               sections: document_struct.sections,
               custom_metadata: custom_metadata
           }}

        true ->
          {:error, "invalid magma_matter type: #{matter_type}"}
      end
    end
  end
end

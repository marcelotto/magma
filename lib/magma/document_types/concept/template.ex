defmodule Magma.Concept.Template do
  @moduledoc false

  alias Magma.Concept

  import Magma.View

  def render(%Concept{subject: %matter_type{} = matter} = concept, artefact_types, assigns) do
    """
    # #{Concept.title(concept)}

    ## #{Concept.description_section_title()}

    #{matter_type.default_description(matter, assigns)}


    # #{Concept.context_knowledge_section_title()}

    #{context_knowledge_hint()}

    #{matter_type.custom_concept_sections(concept)}


    # Artefacts

    #{artefact_sections(concept, artefact_types)}
    """
  end

  def context_knowledge_hint do
    """
    This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

    Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
    """
    |> comment()
  end

  defp artefact_sections(%Concept{} = concept, artefact_types) do
    Enum.map_join(artefact_types, "\n", &(concept |> &1.new!() |> artefact_section()))
  end

  defp artefact_section(%artefact_type{concept: concept} = artefact) do
    """
    ## #{artefact_type.concept_section_title()}

    - Prompt: #{link_to_prompt(artefact)}
    - Final version: #{link_to_version(artefact)}

    ### #{artefact_type.concept_prompt_task_section_title()}

    #{artefact_type.request_prompt_task(concept)}
    """
    |> String.trim_trailing()
  end
end

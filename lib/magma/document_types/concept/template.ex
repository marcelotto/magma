defmodule Magma.Concept.Template do
  alias Magma.Concept

  import Magma.Obsidian.View.Helper

  def render(%Concept{subject: %matter_type{} = matter} = concept, assigns) do
    """
    # #{Concept.title(concept)}

    ## #{Concept.description_section_title()}

    #{matter_type.default_description(matter, assigns)}

    # Knowledge Base

    # Notes

    #{matter_type.custom_sections(concept)}

    # Artefact Prompts

    #{artefact_prompt_sections(concept)}


    # Reference
    """
  end

  defp artefact_prompt_sections(%Concept{subject: %matter_type{}} = concept) do
    Enum.map_join(matter_type.artefacts(), "\n", &artefact_prompt_section(concept, &1))
  end

  defp artefact_prompt_section(concept, artefact_type) do
    """
    ## #{artefact_type.concept_section_title()}

    - Prompt: #{link_to_prompt({concept, artefact_type})}
    - Final version: #{link_to_version({concept, artefact_type})}

    ### #{artefact_type.concept_prompt_section_title()}

    #{artefact_type.task_prompt(concept)}
    """
    |> String.trim_trailing()
  end
end

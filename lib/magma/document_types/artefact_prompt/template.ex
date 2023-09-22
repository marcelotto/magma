defmodule Magma.Artefact.Prompt.Template do
  alias Magma.Artefact.Prompt
  alias Magma.Matter

  import Magma.Obsidian.View.Helper

  def render(%Prompt{artefact: artefact_type} = prompt, project) do
    concept = prompt.concept

    """
    #{controls()}

    # #{prompt.name}

    ## #{Prompt.system_prompt_section_title()}

    #{persona(project)}

    #{artefact_type.system_prompt(concept)}

    ### Description of the #{project.subject.name} project ![[Project#Description]]


    ## #{Prompt.request_prompt_section_title()}

    ### #{transclude(concept, artefact_type.concept_prompt_section_title())}

    ### Description of the #{Matter.type_name(concept.subject.__struct__)} ![[#{concept.name}#Description]]

    #{if matter_representation = concept.subject.__struct__.prompt_representation(concept.subject) do
      "##" <> matter_representation
    end}
    """
  end

  def persona(project) do
    """
    You are MagmaGPT, a software developer on the "#{project.subject.name}" project with a lot of experience with Elixir and writing high-quality documentation.
    """
    |> String.trim_trailing()
  end

  def controls do
    """
    **Generated results**

    #{prompt_results_table()}

    **Actions**

    #{button("Execute", "magma.prompt.exec", color: "blue")}
    #{button("Update", "magma.prompt.update")}
    """
    |> String.trim_trailing()
  end
end

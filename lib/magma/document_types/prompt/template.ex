defmodule Magma.Prompt.Template do
  alias Magma.{Artefact, Prompt, Concept}
  alias Magma.Matter.Project

  import Magma.View

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title
  @request_prompt_section_title "Request"
  def request_prompt_section_title, do: @request_prompt_section_title

  def custom_prompt_obsidian_template(project, prompt) do
    """
    ---
    magma_type: Prompt
    #{Prompt.render_front_matter(prompt)}
    created_at: {{DATE:YYYY-MM-DD[T]HH:mm:ss}}
    tags: #{yaml_list(prompt.tags)}
    aliases: []
    ---
    #{controls(prompt)}

    # {{NAME}}

    ## #{@system_prompt_section_title}

    #{persona(project)}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}

    """
  end

  def render(%Prompt{} = prompt, project) do
    """
    #{controls(prompt)}

    # #{Prompt.title(prompt)}

    ## #{@system_prompt_section_title}

    #{persona(project)}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}

    """
  end

  def render(%Artefact.Prompt{artefact: artefact_type} = prompt, project) do
    concept = prompt.concept

    """
    #{controls(prompt)}

    # #{Artefact.Prompt.title(prompt)}

    ## #{@system_prompt_section_title}

    #{persona(project)}

    #{artefact_type.system_prompt_task(concept)}

    #{context_knowledge(project, concept)}


    ## #{@request_prompt_section_title}

    #{transclude(concept, artefact_type.concept_prompt_task_section_title())}

    #{subject_knowledge(concept)}
    """
  end

  def persona(project) do
    :magma
    |> Application.get_env(
      :persona,
      """
      You are MagmaGPT, an assistant who helps the developers of the "#{project.subject.name}" project during documentation and development. Your responses are in plain and clear English.
      """
    )
    |> String.trim_trailing()
  end

  def context_knowledge(nil) do
    """
    ### Context knowledge

    The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.
    """
    |> String.trim_trailing()
  end

  def context_knowledge(project) do
    """
    #{context_knowledge(nil)}

    #### Description of the #{project.subject.name} project #{transclude("Project", "Description")}
    """
    |> String.trim_trailing()
  end

  def context_knowledge(project, %Concept{subject: %matter_type{}} = concept) do
    """
    #{context_knowledge(unless matter_type == Project, do: project)}

    #{matter_type.context_knowledge(concept)}

    #{transclude(concept, Concept.context_knowledge_section_title())}
    """
    |> String.trim_trailing()
  end

  defp subject_knowledge(%Concept{subject: %matter_type{} = matter} = concept) do
    """
    ### #{matter_type.prompt_concept_description_title(matter)} #{transclude(concept, "Description")}

    #{matter_type.prompt_matter_description(matter)}
    """
    |> String.trim_trailing()
  end

  def controls(%Prompt{}) do
    """

    **Generated results**

    #{prompt_results_table()}

    **Actions**

    #{button("Execute", "magma.prompt.exec", color: "blue")}
    #{button("Execute manually", "magma.prompt.exec-manual", color: "blue")}
    #{button("Copy to clipboard", "magma.prompt.copy")}
    """
    |> String.trim_trailing()
  end

  def controls(%Artefact.Prompt{} = prompt) do
    """

    **Generated results**

    #{prompt_results_table()}

    Final version: #{link_to_version(prompt)}

    **Actions**

    #{button("Execute", "magma.prompt.exec", color: "blue")}
    #{button("Execute manually", "magma.prompt.exec-manual", color: "blue")}
    #{button("Copy to clipboard", "magma.prompt.copy")}
    #{button("Update", "magma.prompt.update")}
    """
    |> String.trim_trailing()
  end
end

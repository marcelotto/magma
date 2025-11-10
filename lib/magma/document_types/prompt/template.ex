defmodule Magma.Prompt.Template do
  @moduledoc false

  alias Magma.{Artefact, Prompt, Session, Concept}
  alias Magma.Matter.Project

  import Magma.View

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title
  @request_prompt_section_title "Request"
  def request_prompt_section_title, do: @request_prompt_section_title

  @replacement_marker "WRITE_RESPONSE_HERE"

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

    #{persona()}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}

    """
  end

  def session_obsidian_template(project, session) do
    """
    ---
    magma_type: Session
    created_at: {{DATE:YYYY-MM-DD[T]HH:mm:ss}}
    tags: #{yaml_list(session.tags)}
    aliases: []
    #{Session.render_front_matter(session)}
    ---
    #{controls(session)}
    ```table-of-contents
    ```
    # {{NAME}}
    ## #{@system_prompt_section_title}

    #{persona()}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}



    #{replacement_marker_prompt("sessions/{{NAME}}.md")}


    ---

    ***Response***

    ---

    ## Response

    #{@replacement_marker}
    """
  end

  def session_continuation_obsidian_template do
    # Note the leading newline, which is required to avoid interpreting the first rule as YAML front matter.
    """

    ---

    ***Prompt***

    ---

    ## Follow-up prompt

    <% tp.file.cursor(1) %>

    #{replacement_marker_prompt("<% tp.file.path(true) %>")}

    ---

    ***Response***

    ---

    ## Response

    #{@replacement_marker}
    """
  end

  def render(%Prompt{} = prompt, project) do
    """
    #{controls(prompt)}

    # #{Prompt.title(prompt)}

    ## #{@system_prompt_section_title}

    #{persona()}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}

    """
  end

  def render(%Session{} = session, project) do
    """
    #{controls(session)}
    ```table-of-contents
    ```
    # #{Session.title(session)}

    ## #{@system_prompt_section_title}

    #{persona()}

    #{context_knowledge(project)}


    ## #{@request_prompt_section_title}



    #{replacement_marker_prompt("sessions/#{session.name}.md")}

    ---

    ***Response***

    ---

    ## Response

    #{@replacement_marker}
    """
  end

  def render(%Artefact.Prompt{artefact: %artefact_type{} = artefact} = prompt, project) do
    concept = artefact.concept

    """
    #{controls(prompt)}

    # #{Artefact.Prompt.title(prompt)}

    ## #{@system_prompt_section_title}

    #{persona()}

    #{artefact_type.system_prompt_task(concept)}

    #{context_knowledge(project, concept, artefact_type)}


    ## #{@request_prompt_section_title}

    #{transclude(concept, artefact_type.concept_prompt_task_section_title())}

    #{subject_knowledge(concept)}
    """
  end

  defp persona, do: Magma.Config.System.persona_transclusion()

  def context_knowledge(nil) do
    """
    ### Context knowledge

    The following sections contain background knowledge you need to be aware of.

    #{Magma.Config.System.context_knowledge_transclusion()}
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

  def context_knowledge(project, %Concept{subject: %matter_type{}} = concept, artefact_type) do
    """
    #{context_knowledge(unless matter_type == Project, do: project)}

    #{matter_type.context_knowledge(concept)}

    #{artefact_type.context_knowledge(concept)}

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

  defp replacement_marker_prompt(document_path) do
    full_path =
      Magma.Vault.path()
      |> Path.relative_to_cwd()
      |> Path.join(document_path)

    """
    **Response Instructions:**

    Use the Edit tool to replace the line starting with "#{@replacement_marker}" in `#{full_path}`:

    - Pure discussion → Write complete response there (not in chat)
    - Coding task → Complete work first, then write summary there (files changed, decisions made)

    ALWAYS use Edit tool - do NOT output main response in chat.
    Do NOT read the file first - it just contains the conversation we're currently having - use Edit tool directly to replace the marker.
    """
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

  def controls(%Session{}) do
    """

    **Actions**

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

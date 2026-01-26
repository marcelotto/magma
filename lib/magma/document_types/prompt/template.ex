defmodule Magma.Prompt.Template do
  @moduledoc false

  alias Magma.{Prompt, Session}

  import Magma.View

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title
  @request_prompt_section_title "Request"
  def request_prompt_section_title, do: @request_prompt_section_title

  def custom_prompt_obsidian_template(prompt) do
    """
    ---
    magma_type: Prompt
    #{Prompt.render_front_matter(prompt)}
    created_at: {{DATE:YYYY-MM-DD[T]HH:mm:ss}}
    tags: #{yaml_list(prompt.tags)}
    aliases: []
    ---
    #{prompt_body(prompt, "{{NAME}}")}
    """
  end

  def render(%Session{} = session), do: Session.Template.render(session)

  def render(%Prompt{} = prompt) do
    prompt_body(prompt, Prompt.title(prompt))
  end

  defp prompt_body(prompt, title) do
    """
    #{controls(prompt)}

    # #{title}

    ## #{@system_prompt_section_title}

    #{persona()}

    #{context_knowledge()}


    ## #{@request_prompt_section_title}

    """
  end

  def persona, do: Magma.Config.System.persona_transclusion()

  def context_knowledge do
    """
    ### Context knowledge

    The following sections contain background knowledge you need to be aware of.

    #{Magma.Config.System.context_knowledge_transclusion()}
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

  def controls(%Session{}) do
    """

    **Actions**

    #{button("Copy to clipboard", "magma.prompt.copy")}
    """
    |> String.trim_trailing()
  end
end

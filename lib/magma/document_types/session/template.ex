defmodule Magma.Session.Template do
  @moduledoc false

  alias Magma.{Prompt, Session}

  import Magma.View
  import Magma.Utils, only: [file_format_timestamp: 0]

  @replacement_marker "WRITE_RESPONSE_HERE"

  def render(%Session{} = session) do
    session_body(session, Session.title(session))
  end

  defp session_body(session, title) do
    """
    #{Prompt.Template.controls(session)}
    ```table-of-contents
    ```
    # #{title}

    ## #{Prompt.Template.context_section_title()}

    ### Knowledge Base

    Read the following documents carefully:

    -

    ## #{Prompt.Template.task_section_title()}
    #{build_response_section(Session.response_mode(session))}



    ----

    ***Notes***

    ----
    #{button("Copy last prompt to clipboard", "magma.prompt.copy")}
    # Notes

    """
  end

  defp build_response_section(:disabled), do: ""
  defp build_response_section(:enabled), do: response_block(import_response_button())
  defp build_response_section(:auto), do: response_block(import_response_button())

  defp response_block(content) do
    """

    ----

    ***Response***

    ----
    ## Response

    #{content}
    """
  end

  def import_response_button do
    button("Import Response", "magma.session.import_response", color: "blue")
  end

  def session_obsidian_template(session) do
    """
    ---
    magma_type: Session
    created_at: {{DATE:YYYY-MM-DD[T]HH:mm:ss}}
    tags: #{yaml_list(session.tags)}
    aliases: []
    #{Session.render_front_matter(session)}
    ---
    #{session_body(session, "{{NAME}}")}
    """
  end

  def session_continuation_obsidian_template do
    # Note the leading newline, which is required to avoid interpreting the first rule as YAML front matter.
    """

    ----

    ***Prompt***

    ----
    ## Follow-up prompt

    <% tp.file.cursor(1) %>
    #{build_response_section(Magma.Config.system(:session_response_mode))}
    """
  end

  def session_response_prompt_eex_template do
    """
    Apply the "respond-in-file-rule" from CLAUDE.md and write your response to `<%= @response_file_path %>`
    """
  end

  def respond_in_file_rule do
    """
    ## Respond-in-file Rule

    When instructed to apply the respond-in-file rule with a specific file path:

    1. **Write response to specified file** using Edit tool
       - Start with `## Response: ` followed by a descriptive title
       - Content identical to what would be written in chat

    2. **Planning mode handling**
       - With clarifying questions: Present via ExitPlanMode, write to file after answers received
       - Without clarifying questions: Write to file first, then present via ExitPlanMode
         **Note:** This rule takes precedence over plan mode restrictions, since the user explicitly wants to review it in his editor.

    3. **Never output main response in chat** - always use Edit tool

    4. **Post-response**: Return to conversation and confirm completion
    """
  end

  @doc """
  Renders the session response prompt from the EEx template.

  Provides all available assigns for both direct replacement and external file workflows.

  ## Available Template Variables
  - `@session_name` - Session document name
  - `@session_file` - Vault-relative path to session file
  - `@response_file_path` - Path for external response file
  - `@timestamp` - Timestamp for response file
  - `@replacement_marker` - Marker string for direct replacement
  - `@vault_path` - Absolute path to vault root
  """
  @spec render_session_response_prompt(Session.t()) :: String.t()
  def render_session_response_prompt(%Session{} = session) do
    vault_path = Path.dirname(Magma.Vault.path())
    template_path = Magma.Vault.session_response_prompt_template_path()
    timestamp = file_format_timestamp()

    assigns = [
      session_name: session.name,
      session_file: Path.relative_to(session.path, vault_path),
      response_file_path:
        session.name
        |> Magma.Vault.session_response_file_path(timestamp)
        |> Path.relative_to(vault_path),
      timestamp: timestamp,
      replacement_marker: @replacement_marker,
      vault_path: Magma.Vault.path()
    ]

    if File.exists?(template_path) do
      EEx.eval_file(template_path, assigns: assigns)
    else
      # Fallback: evaluate template generator directly (for vaults not yet migrated)
      EEx.eval_string(session_response_prompt_eex_template(), assigns: assigns)
    end
  end
end

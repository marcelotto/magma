defmodule Magma.Prompt.Assembler do
  @moduledoc false

  alias Magma.{Prompt, Session, DocumentStruct}
  alias Magma.DocumentStruct.Section

  import Magma.Utils.Guards

  require Logger

  def assemble_parts(prompt) when is_prompt(prompt) do
    with {:ok, section} <- section(prompt) do
      context_section =
        section[Prompt.Template.context_section_title()] ||
          section[Prompt.Template.context_section_fallback_title()]

      task_section =
        section[Prompt.Template.task_section_title()] ||
          section[Prompt.Template.task_section_fallback_title()]

      if task_section do
        if Enum.count(section.sections) > if(context_section, do: 2, else: 1),
          do: ignored_section_detected(prompt.path)

        system_prompt =
          if context_section,
            do: compile(context_section, include_header: false),
            else: nil

        {:ok, system_prompt, compile(task_section, include_header: false)}
      else
        {:error, "no task section found in #{prompt.path}"}
      end
    end
  end

  def assemble_all(%Session{} = session) do
    with {:ok, assembled_content} <- assemble_session(session) do
      {:ok, append_response_instruction(assembled_content, session)}
    end
  end

  def assemble_all(prompt) when is_prompt(prompt) do
    with {:ok, section} <- section(prompt) do
      {:ok, compile(section, include_header: include_header?(prompt))}
    end
  end

  defp assemble_session(session) do
    case Session.mode(session) do
      :initial ->
        case session.parts do
          [{:initial, ast} | _] ->
            assemble_from_ast(ast, session.path, include_header: include_header?(session))

          _ ->
            {:error, "no initial part found in session"}
        end

      :continuation ->
        if ast_nodes = Session.last_prompt_part(session) do
          assemble_from_ast(ast_nodes, session.path, include_header: false)
        else
          {:error, "no prompt sections found in continuation mode"}
        end
    end
  end

  @doc """
  Appends response instruction to assembled prompt based on session_response_mode.

  Checks the session's `response_mode` field, falling back to system config.

  - `:disabled` - No instruction appended
  - `:enabled` - Always appends instruction
  - `:auto` - Appends instruction only if import button is present in session content
  """
  def append_response_instruction(content, %Session{} = session) do
    session
    |> Session.response_mode()
    |> do_append_response_instruction(content, session)
  end

  defp do_append_response_instruction(:disabled, content, _session), do: content

  defp do_append_response_instruction(:enabled, content, session) do
    "#{content}\n\n#{Session.Template.render_session_response_prompt(session)}"
  end

  defp do_append_response_instruction(:auto, content, session) do
    if String.contains?(session.content, Session.Template.import_response_button()) do
      do_append_response_instruction(:enabled, content, session)
    else
      do_append_response_instruction(:disabled, content, session)
    end
  end

  @doc false
  def assemble_from_ast(ast_nodes, path, opts \\ []) when is_list(ast_nodes) do
    with {:ok, document_struct} <- DocumentStruct.Parser.to_section(ast_nodes) do
      if Enum.count(document_struct.sections) > 1, do: ignored_section_detected(path)

      main_section = DocumentStruct.main_section(document_struct)
      {:ok, compile(main_section, opts)}
    end
  end

  defp section(prompt) do
    with {:ok, document_struct} <- DocumentStruct.parse(prompt.content) do
      if Enum.count(document_struct.sections) > 1, do: ignored_section_detected(prompt.path)

      {:ok, DocumentStruct.main_section(document_struct)}
    end
  end

  defp ignored_section_detected(path) do
    Logger.warning(
      "Prompt #{path} contains subsections which won't be taken into account. Put them under the task section if you want that."
    )
  end

  defp include_header?(document) do
    Map.get(
      document.custom_metadata,
      :include_prompt_header,
      Magma.Config.system(:include_prompt_header)
    )
  end

  defp compile(section, opts) do
    include_header =
      Keyword.get(opts, :include_header, Magma.Config.system(:include_prompt_header))

    section
    |> Section.resolve_transclusions()
    |> Section.resolve_links()
    |> Section.remove_comments()
    |> Section.to_markdown(header: include_header, level: if(include_header, do: 1, else: 0))
  end

  def copy_to_clipboard(prompt) when is_prompt(prompt) do
    with {:ok, content} <- assemble_all(prompt),
         content when is_binary(content) <- Clipboard.copy(content) do
      {:ok, content}
    end
  end
end

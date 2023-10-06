defmodule Magma.Prompt.Assembler do
  @moduledoc false

  alias Magma.{Prompt, DocumentStruct}
  alias Magma.DocumentStruct.Section

  import Magma.Utils.Guards

  require Logger

  def assemble_parts(prompt) when is_prompt(prompt) do
    with {:ok, section} <- section(prompt) do
      system_prompt_section = section[Prompt.Template.system_prompt_section_title()]
      request_prompt_section = section[Prompt.Template.request_prompt_section_title()]

      cond do
        !system_prompt_section ->
          {:error, "no system prompt section found in #{prompt.path}"}

        !request_prompt_section ->
          {:error, "no request prompt section found in #{prompt.path}"}

        true ->
          if Enum.count(section.sections) > 2, do: ignored_section_detected(prompt)

          {
            :ok,
            compile(system_prompt_section),
            compile(request_prompt_section)
          }
      end
    end
  end

  def assemble_all(prompt) when is_prompt(prompt) do
    with {:ok, section} <- section(prompt) do
      {:ok, compile(section)}
    end
  end

  defp section(prompt) do
    with {:ok, document_struct} <- DocumentStruct.parse(prompt.content) do
      if Enum.count(document_struct.sections) > 1, do: ignored_section_detected(prompt)

      {:ok, DocumentStruct.main_section(document_struct)}
    end
  end

  defp ignored_section_detected(prompt) do
    Logger.warning(
      "Prompt #{prompt.path} contains subsections which won't be taken into account. Put them under the request section if you want that."
    )
  end

  defp compile(section) do
    section
    |> Section.resolve_transclusions()
    |> Section.remove_comments()
    |> Section.to_string(header: false, level: 0)
  end

  def copy_to_clipboard(prompt) when is_prompt(prompt) do
    case assemble_all(prompt) do
      {:ok, content} -> Clipboard.copy(content)
      {:error, error} -> raise error
    end
  end
end

defmodule Magma.Config.Artefact do
  use Magma.Config.Document, fields: [:artefact_type]

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section

  @system_prompt_section "System prompt"
  def system_prompt_section, do: @system_prompt_section

  @task_prompt_section "Task prompt"
  def task_prompt_section, do: @task_prompt_section

  @context_knowledge_section "Context knowledge"
  def context_knowledge_section, do: @context_knowledge_section

  @impl true
  def title(%__MODULE__{artefact_type: artefact_type}),
    do: "#{Magma.Artefact.type_name(artefact_type, false)} artefact config"

  @impl true
  def build_path(%__MODULE__{artefact_type: artefact_type}),
    do: {:ok, Magma.Config.artefacts_path("#{name_by_type(artefact_type)}.md")}

  def name_by_type(artefact_type), do: "#{Magma.Artefact.type_name(artefact_type)}.config"

  def render_request_prompt(%__MODULE__{} = artefact_config, bindings) do
    artefact_config
    |> DocumentStruct.section_by_title(@task_prompt_section)
    |> Section.preserve_eex_tags()
    |> Section.to_markdown(header: false)
    |> String.trim()
    |> EEx.eval_string(bindings)
  end
end

defmodule Magma.Config.Artefact do
  use Magma.Config.Document, fields: [:artefact_type]

  alias Magma.{DocumentStruct, View}
  alias Magma.DocumentStruct.Section

  @impl true
  def title(%__MODULE__{artefact_type: artefact_type}),
    do: "#{Magma.Artefact.type_name(artefact_type, false)} artefact config"

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title

  @task_prompt_section_title "Task prompt"
  def task_prompt_section_title, do: @task_prompt_section_title

  @impl true
  def build_path(%__MODULE__{artefact_type: artefact_type}),
    do: {:ok, Magma.Config.artefacts_path("#{name_by_type(artefact_type)}.md")}

  def name_by_type(artefact_type), do: "#{Magma.Artefact.type_name(artefact_type)}.config"

  def render_request_prompt(%__MODULE__{} = artefact_config, bindings) do
    artefact_config
    |> DocumentStruct.section_by_title(@task_prompt_section_title)
    |> Section.preserve_eex_tags()
    |> Section.to_markdown(header: false)
    |> String.trim()
    |> EEx.eval_string(bindings)
  end

  def context_knowledge_transclusion(artefact_type) do
    artefact_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end

defmodule Magma.Artefact.PromptResult.Template do
  use Magma.Document.Template

  alias Magma.Artefact

  require EEx

  @path Magma.Document.template_path() |> Path.join("artefact_prompt_result.md")

  @impl true
  def render(artefact_prompt, assigns \\ [])

  def render(%Artefact.PromptResult{} = result, _assigns) do
    do_render(result, result.prompt)
  end

  EEx.function_from_file(:defp, :do_render, @path, [:result, :prompt])
end

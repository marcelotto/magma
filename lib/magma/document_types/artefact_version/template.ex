defmodule Magma.Artefact.Version.Template do
  use Magma.Document.Template

  alias Magma.Artefact

  require EEx

  @path Magma.Document.template_path() |> Path.join("artefact_version.md")

  @impl true
  def render(artefact_prompt, assigns \\ [])

  def render(%Artefact.Version{} = version, _assigns) do
    do_render(version, version.prompt_result)
  end

  EEx.function_from_file(:defp, :do_render, @path, [:version, :prompt_result])
end

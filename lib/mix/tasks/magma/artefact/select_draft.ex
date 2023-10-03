defmodule Mix.Tasks.Magma.Artefact.SelectDraft do
  @shortdoc "Selects a prompt result as a draft version"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, PromptResult}

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("prompt result name or path missing")

      _opts, [prompt_result_name] ->
        {:ok, _} =
          prompt_result_name
          |> PromptResult.load!()
          |> Artefact.Version.create()
    end)
  end
end

defmodule Mix.Tasks.Magma.Artefact.SelectDraft do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, PromptResult}

  @shortdoc "Selects a prompt result as a draft version"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt result name or path missing")

      _opts, [prompt_result_name] ->
        with {:ok, prompt_result} <- PromptResult.load(prompt_result_name),
             {:ok, _} <- Artefact.Version.create(prompt_result) do
          :ok
        else
          error -> handle_error(error)
        end
    end)
  end
end

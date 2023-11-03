defmodule Mix.Tasks.Magma.Prompt.Update do
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Document}

  @shortdoc "Regenerates a artefact prompt"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt name or path missing")

      _opts, [prompt_name] ->
        with {:ok, prompt} <- Artefact.Prompt.load(prompt_name),
             {:ok, _} <- Document.recreate(prompt) do
          :ok
        else
          error -> handle_error(error)
        end
    end)
  end
end

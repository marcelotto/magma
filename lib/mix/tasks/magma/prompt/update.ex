defmodule Mix.Tasks.Magma.Prompt.Update do
  @shortdoc "Regenerates a prompt"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Document}

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("prompt name or path missing")

      _opts, [prompt_name] ->
        prompt_name
        |> Artefact.Prompt.load!()
        |> Document.recreate!()
    end)
  end
end

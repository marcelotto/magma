defmodule Mix.Tasks.Magma.Prompt.Copy do
  @shortdoc "Copies the given prompt to the clipboard"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Artefact

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("prompt name or path missing")

      _opts, [prompt_name] ->
        prompt_name
        |> Artefact.Prompt.load!()
        |> Artefact.Prompt.to_clipboard()
    end)
  end
end

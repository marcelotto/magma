defmodule Mix.Tasks.Magma.Prompt.Exec do
  @shortdoc "Executes a prompt"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Artefact

  @options [
    trim_header: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("prompt name or path missing")

      opts, [prompt_name] ->
        {:ok, _} =
          prompt_name
          |> Artefact.Prompt.load!()
          |> Artefact.PromptResult.create([], opts)
    end)
  end
end

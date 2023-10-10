defmodule Mix.Tasks.Magma.Prompt.Exec do
  @shortdoc "Executes a prompt"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Generation, PromptResult}
  alias Magma.Document.Loader

  # TODO: add Magma.Generation options
  @options [
    trim_header: :boolean,
    manual: :boolean,
    interactive: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("prompt name or path missing")

      opts, [prompt_name] ->
        {attrs, opts} =
          case Keyword.pop(opts, :manual, false) do
            {true, opts} -> {[generation: Generation.Manual.new!()], opts}
            {_, opts} -> {[], opts}
          end

        {:ok, _} =
          Loader.with_prompt(prompt_name, &PromptResult.create(&1, attrs, opts))
    end)
  end
end

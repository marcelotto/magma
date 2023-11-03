defmodule Mix.Tasks.Magma.Prompt.Exec do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Generation, PromptResult}
  alias Magma.Document.Loader

  @shortdoc "Executes a prompt"

  # TODO: add Magma.Generation options
  @options [
    manual: :boolean,
    interactive: :boolean,
    trim_header: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt name or path missing")

      opts, [prompt_name] ->
        {attrs, opts} =
          case Keyword.pop(opts, :manual, false) do
            {true, opts} -> {[generation: Generation.Manual.new!()], opts}
            {_, opts} -> {[], opts}
          end

        prompt_name
        |> Loader.with_prompt(&PromptResult.create(&1, attrs, opts))
        |> handle_error()
    end)
  end
end

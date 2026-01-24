defmodule Mix.Tasks.Magma.Prompt.Exec do
  use Magma
  use Mix.Task

  import Magma.CLI.Helper

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
        {:error, "prompt name or path missing"}

      opts, [prompt_name] ->
        {attrs, opts} =
          case Keyword.pop(opts, :manual, false) do
            {true, opts} -> {[generation: Generation.Manual.new!()], opts}
            {_, opts} -> {[], opts}
          end

        Loader.with_prompt(prompt_name, &PromptResult.create(&1, attrs, opts))
    end)
    |> handle_mix_result()
  end
end

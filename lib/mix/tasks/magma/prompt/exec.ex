defmodule Mix.Tasks.Magma.Prompt.Exec do
  @moduledoc """
  Executes a prompt.

      $ mix magma.prompt.exec "Name of prompt"

  Using `--manual` copies the rendered prompt to the clipboard for pasting into
  an LLM interface. By default, you'll be asked to paste back the result:

      $ mix magma.prompt.exec "Name of prompt" --manual

  Use `--no-interactive` to skip the paste-back prompt and create an empty result
  document (useful for Obsidian buttons).

  ## Configuration

  Default generation settings can be configured in `config.exs`:

      config :magma,
        default_generation: Magma.Generation.OpenAI

      config :magma, Magma.Generation.OpenAI,
        model: "gpt-4",
        temperature: 0.6

  ## Options

  - `--manual` - Copy prompt to clipboard for manual execution
  - `--no-interactive` - Skip interactive paste-back prompt
  - `--trim-header` - Trim the header from the rendered prompt
  """

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

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

  @shortdoc Magma.CLI.Command.ExecPrompt.description()
  @requirements ["app.start"]

  def run(args) do
    args
    |> Magma.CLI.Command.ExecPrompt.run()
    |> handle_mix_result()
  end
end

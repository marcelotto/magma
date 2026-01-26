defmodule Mix.Tasks.Magma.Prompt.Gen do
  @moduledoc """
  Generates a custom prompt document.

      $ mix magma.prompt.gen "Prompt for something"

  ## Options

  - `--force` - Overwrite existing documents without confirmation
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.Prompt

  @shortdoc "Generates a custom prompt document"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        {:error, "prompt name missing"}

      _opts, [prompt_name] ->
        Prompt.create(prompt_name)
    end)
    |> handle_mix_result()
  end
end

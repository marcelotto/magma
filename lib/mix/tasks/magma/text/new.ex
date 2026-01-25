defmodule Mix.Tasks.Magma.Text.New do
  @moduledoc """
  Generates concept and artefact prompt documents for a new text.

  The first argument is the title, optionally followed by a text type that
  determines the system prompt details.

      $ mix magma.text.new "Example User Guide" UserGuide

  ## Options

  - `--force` - Overwrite existing documents without confirmation
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.Text

  @shortdoc "Generates a new text concept"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> {:error, "text name missing"}
      _opts, [text_name] -> Text.create(text_name)
      _opts, [text_name, text_type_name] -> Text.create(text_name, text_type_name)
    end)
    |> handle_mix_result()
  end
end

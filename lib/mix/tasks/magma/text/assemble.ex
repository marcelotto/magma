defmodule Mix.Tasks.Magma.Text.Assemble do
  @moduledoc """
  Generates section documents from a final table of contents.

  Creates concept and artefact prompt documents for each section and assembles
  the preview document.

      $ mix magma.text.assemble "Name of ToC document"

  ## Options

  - `--force` - Overwrite existing documents without confirmation
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.Text.Assembler

  @shortdoc "Generates the documents for the sections of a text"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> {:error, "concept or toc name missing"}
      opts, [document_name] -> Assembler.assemble(document_name, opts)
    end)
    |> handle_mix_result()
  end
end

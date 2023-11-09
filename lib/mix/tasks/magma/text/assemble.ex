defmodule Mix.Tasks.Magma.Text.Assemble do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Text.Assembler

  @shortdoc "Generates the documents for the sections of a text"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> error("concept or toc name missing")
      opts, [document_name] -> Assembler.assemble(document_name, opts) |> handle_error()
    end)
  end
end

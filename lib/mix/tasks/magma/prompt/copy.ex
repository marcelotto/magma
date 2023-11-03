defmodule Mix.Tasks.Magma.Prompt.Copy do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Document.Loader
  alias Magma.Prompt.Assembler

  @shortdoc "Copies the given prompt in compiled form to the clipboard"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("prompt name or path missing")

      _opts, [prompt_name] ->
        prompt_name
        |> Loader.with_prompt(&Assembler.copy_to_clipboard/1)
        |> handle_error()
    end)
  end
end

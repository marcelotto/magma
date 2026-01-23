defmodule Magma.CLI.Command.CopyPrompt do
  use Magma.CLI.Command

  alias Magma.Document.Loader
  alias Magma.Prompt.Assembler

  @impl true
  def name, do: "copy-prompt"

  @impl true
  def description, do: "Copy compiled prompt to clipboard"

  @impl true
  def run(args) do
    with_valid_options(args, [], fn
      _opts, [] ->
        abort("prompt name or path missing")

      _opts, [prompt_name] ->
        prompt_name
        |> Loader.with_prompt(&Assembler.copy_to_clipboard/1)
        |> handle_error()
    end)
  end
end

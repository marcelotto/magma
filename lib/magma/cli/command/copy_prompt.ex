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
      _opts, [] -> {:error, "prompt name or path missing"}
      _opts, [prompt_name] -> Loader.with_prompt(prompt_name, &Assembler.copy_to_clipboard/1)
    end)
  end
end

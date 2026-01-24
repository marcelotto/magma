defmodule Mix.Tasks.Magma.Prompt.Copy do
  use Mix.Task

  import Magma.CLI.Helper

  @shortdoc Magma.CLI.Command.CopyPrompt.description()
  @requirements ["app.start"]

  def run(args) do
    args
    |> Magma.CLI.Command.CopyPrompt.run()
    |> handle_mix_result()
  end
end

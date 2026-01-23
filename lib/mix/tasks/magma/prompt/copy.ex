defmodule Mix.Tasks.Magma.Prompt.Copy do
  use Mix.Task

  @shortdoc Magma.CLI.Command.CopyPrompt.description()
  @requirements ["app.start"]

  def run(args), do: Magma.CLI.Command.CopyPrompt.run(args)
end

defmodule Mix.Tasks.Magma.Session.ImportResponse do
  use Mix.Task

  @shortdoc Magma.CLI.Command.ImportSession.description()
  @requirements ["app.start"]

  def run(args), do: Magma.CLI.Command.ImportSession.run(args)
end

defmodule Mix.Tasks.Magma.Session.ImportResponse do
  use Mix.Task

  import Magma.CLI.Helper

  @shortdoc Magma.CLI.Command.ImportSession.description()
  @requirements ["app.start"]

  def run(args) do
    args
    |> Magma.CLI.Command.ImportSession.run()
    |> handle_mix_result()
  end
end

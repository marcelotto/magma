defmodule Mix.Tasks.Magma.Vault.Init do
  use Mix.Task

  import Magma.CLI.Helper

  @shortdoc Magma.CLI.Command.Init.description()
  @requirements ["app.start"]

  def run(args) do
    args
    |> Magma.CLI.Command.Init.run()
    |> handle_mix_result()
  end
end

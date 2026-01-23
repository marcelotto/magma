defmodule Mix.Tasks.Magma.Vault.Init do
  use Mix.Task

  @shortdoc Magma.CLI.Command.Init.description()
  @requirements ["app.start"]

  def run(args), do: Magma.CLI.Command.Init.run(args)
end

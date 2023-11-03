defmodule Mix.Tasks.Magma.Vault.Sync.Code do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Vault.CodeSync

  @shortdoc "Syncs the module docs in the vault with the ones in lib"

  @options [
    force: :boolean,
    all: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn opts, [] ->
      opts
      |> CodeSync.sync()
      |> handle_error()
    end)
  end
end

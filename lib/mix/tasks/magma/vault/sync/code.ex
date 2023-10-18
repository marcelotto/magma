defmodule Mix.Tasks.Magma.Vault.Sync.Code do
  @shortdoc "Syncs the module docs in the vault with the ones in lib"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Vault.CodeSync

  @options [
    force: :boolean,
    all: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn opts, _remaining ->
      CodeSync.sync(opts)
    end)
  end
end

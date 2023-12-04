defmodule Mix.Tasks.Magma.Vault.Migrate do
  @shortdoc "Migrates the Magma vault to a newer Magma version"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper
  alias Magma.Vault.Migration

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, _ -> Migration.migrate()
    end)
  end
end

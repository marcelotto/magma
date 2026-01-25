defmodule Mix.Tasks.Magma.Vault.Sync.Code do
  @moduledoc """
  Syncs module documents in the vault with the codebase.

  Creates `Magma.Concept` and `Magma.Artefact.Prompt` documents for all public,
  non-ignored modules.

  A module is ignored if:
  - It has a `# Magma pragma: ignore` comment at the start
  - It is marked hidden (`@moduledoc false`) without a `# Magma pragma: include` comment

  ## Configuration

  Add default tags to all generated documents:

      config :magma,
        default_tags: ["magma-vault"]

  ## Options

  - `--force` - Overwrite existing documents without confirmation
  - `--all` - Include modules that already have documents
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.Vault.CodeSync

  @shortdoc "Syncs the module docs in the vault with the ones in lib"

  @options [
    force: :boolean,
    all: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn opts, [] ->
      CodeSync.sync(opts)
    end)
    |> handle_mix_result()
  end
end

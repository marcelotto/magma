defmodule Mix.Tasks.Magma.Vault.Init do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Vault.Initializer

  @shortdoc "Initializes the Magma vault directory"

  @options [
    force: :boolean,
    base_vault: :string,
    base_vault_path: :string,
    code_sync: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("project name missing")

      opts, [project_name] ->
        project_name
        |> Initializer.initialize(base_vault(opts), opts)
        |> handle_error()
    end)
  end

  defp base_vault(opts) do
    cond do
      base_vault_theme = Keyword.get(opts, :base_vault) -> String.to_atom(base_vault_theme)
      base_vault_path = Keyword.get(opts, :base_vault_path) -> base_vault_path
      true -> nil
    end
  end
end

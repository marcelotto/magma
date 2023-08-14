defmodule Mix.Tasks.Magma.Vault.Init do
  @shortdoc "Initializes the Magma vault directory"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Vault.Initializer

  @options [
    base_vault: :string,
    base_vault_path: :string
  ]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("project name missing")

      opts, [project_name] ->
        Initializer.initialize(project_name, base_vault(opts))
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

defmodule Mix.Tasks.Magma.Vault.Init do
  @shortdoc "Initializes the Magma vault directory"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Vault.Initializer

  @options [
    force: :boolean,
    base_vault: :string,
    base_vault_path: :string,
    code_sync: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("project name missing")

      opts, [project_name] ->
        case Initializer.initialize(project_name, base_vault(opts), opts) do
          :ok -> :ok
          {:error, error} -> raise inspect(error)
        end
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

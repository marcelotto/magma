defmodule Magma.CLI.Command.Init do
  use Magma.CLI.Command

  alias Magma.Vault.Initializer

  @options [
    force: :boolean,
    base_vault: :string,
    base_vault_path: :string
  ]

  @impl true
  def name, do: "init"

  @impl true
  def description, do: "Initialize a new Magma vault"

  @impl true
  def run(args) do
    with_valid_options(args, @options, fn
      opts, _ -> Initializer.initialize(base_vault(opts), opts)
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

defmodule Magma.CLI.Command.Init do
  use Magma.CLI.Command

  alias Magma.CLI.FileOps
  alias Magma.Vault
  alias Vault.{Discovery, Initializer}

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
      opts, [] -> Initializer.initialize(base_vault(opts), opts)
      opts, [path] -> initialize_at_path(path, base_vault(opts), opts)
      _opts, _extra -> {:error, "Too many arguments. Usage: magma init [path]"}
    end)
  end

  defp initialize_at_path(path, base_vault, opts) do
    expanded_path = Path.expand(path)
    default_path = Vault.path()

    Application.put_env(:magma, :dir, expanded_path)

    with :ok <- Initializer.initialize(base_vault, opts) do
      maybe_create_magma_yaml(expanded_path, default_path)
    end
  end

  defp maybe_create_magma_yaml(vault_path, default_path) do
    cwd = File.cwd!()

    if vault_path == cwd or vault_path == default_path do
      :ok
    else
      create_magma_yaml(cwd, vault_path)
    end
  end

  defp create_magma_yaml(cwd, vault_path) do
    config_path = Path.join(cwd, Discovery.config_file())
    relative_path = Path.relative_to(vault_path, cwd)
    path_to_write = if relative_path == vault_path, do: vault_path, else: relative_path

    FileOps.create_file(config_path, "vault: #{path_to_write}\n")
    :ok
  end

  defp base_vault(opts) do
    cond do
      base_vault_theme = Keyword.get(opts, :base_vault) -> String.to_atom(base_vault_theme)
      base_vault_path = Keyword.get(opts, :base_vault_path) -> base_vault_path
      true -> nil
    end
  end
end

defmodule Magma.Vault.Discovery do
  @config_file ".magma.yaml"
  @env_var "MAGMA_VAULT_PATH"

  @moduledoc """
  Discovers the Magma vault path.

  The discovery follows this priority order:
  1. Environment variable (`#{@env_var}`)
  2. Current directory if it contains a `magma.config/` subdirectory (i.e., is a vault)
  3. Project-local config file (`#{@config_file}`)

  If none is found, returns `nil` and lets the existing application
  config or default in `Magma.Vault.path/0` take effect.
  """

  require Logger

  @doc """
  Resolves the vault path from environment variable, current directory, or `#{@config_file}`.

  Returns the discovered path or `nil` if not found.
  """
  @spec resolve() :: Path.t() | nil
  def resolve do
    from_env() || from_current_directory() || from_config_file()
  end

  @doc """
  Resolves and applies the vault path configuration.

  If a vault path is discovered, updates the application environment
  so that `Magma.Vault.path/0` returns the discovered path.
  If nothing is found, leaves the application config unchanged.

  Always returns `:ok`.
  """
  @spec apply() :: :ok
  def apply do
    if path = resolve() do
      Application.put_env(:magma, :dir, path)
    end

    :ok
  end

  defp from_env do
    @env_var |> System.get_env() |> validate_path()
  end

  defp from_current_directory do
    cwd = File.cwd!()
    if File.dir?(Path.join(cwd, "magma.config")), do: cwd
  end

  defp from_config_file do
    config_path = Path.expand(@config_file)

    if File.exists?(config_path) do
      case YamlElixir.read_from_file(config_path) do
        {:ok, %{"vault" => vault_path}} ->
          validate_path(vault_path)

        {:ok, _} ->
          nil

        {:error, error} ->
          Logger.warning("Error reading #{config_path}: #{inspect(error)}")
          nil
      end
    end
  end

  defp validate_path(""), do: nil

  defp validate_path(path) when is_binary(path) do
    path = Path.expand(path)
    if File.dir?(path), do: path
  end

  defp validate_path(_), do: nil
end

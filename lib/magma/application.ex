defmodule Magma.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Magma.Vault.Discovery.apply()

    children = [
      Magma.Vault.Index,
      Magma.Config
    ]

    opts = [strategy: :one_for_one, name: Magma.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      if System.get_env("__BURRITO") == "1" do
        spawn(fn -> Magma.CLI.main() end)
      end

      {:ok, pid}
    end
  end
end

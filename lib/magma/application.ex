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
    Supervisor.start_link(children, opts)
  end
end

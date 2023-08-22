defmodule Magma.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Magma.Vault.Index
    ]

    opts = [strategy: :one_for_one, name: Magma.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

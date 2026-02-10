defmodule Magma.CLI.Command.Version do
  @moduledoc "CLI command to show the Magma version."

  use Magma.CLI.Command

  alias Magma.CLI

  @impl true
  def name, do: "version"

  @impl true
  def description, do: "Show Magma version"

  @impl true
  def run(_args) do
    IO.puts("Magma v#{CLI.version()}")
    :ok
  end
end

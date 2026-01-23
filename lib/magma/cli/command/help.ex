defmodule Magma.CLI.Command.Help do
  use Magma.CLI.Command

  alias Magma.CLI

  @impl true
  def name, do: "help"

  @impl true
  def description, do: "Show available commands"

  @impl true
  def run(_args) do
    IO.puts("Magma\n")
    IO.puts("Usage: magma <command> [options] [arguments]\n")
    IO.puts("Commands:")

    CLI.commands()
    |> Enum.sort_by(fn {name, _} -> name end)
    |> Enum.each(fn {name, module} ->
      IO.puts("  #{String.pad_trailing(name, 16)} #{module.description()}")
    end)

    :ok
  end
end

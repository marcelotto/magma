defmodule Magma.CLI do
  @moduledoc "Main entry point for the Magma CLI."

  alias Magma.CLI.Command
  alias Magma.CLI.IO, as: CLI

  @commands [Command.Init, Command.Help, Command.CopyPrompt, Command.ImportSession]
            |> Map.new(&{&1.name(), &1})

  @doc "Returns the map of registered commands."
  def commands, do: @commands

  @doc "Runs the CLI with the given arguments."
  def run([]), do: Command.Help.run([])

  def run([command_name | args]) do
    case @commands[command_name] do
      nil ->
        {:error, "Unknown command: #{command_name}. Run 'magma help' for available commands."}

      command_module ->
        args
        |> command_module.run()
        |> exit_code()
    end
  end

  defp exit_code(:ok), do: 0
  defp exit_code({:ok, code}) when is_integer(code), do: code

  defp exit_code({:error, error}) do
    CLI.error(to_string(error))
    1
  end

  defp exit_code(:abort), do: :abort
end

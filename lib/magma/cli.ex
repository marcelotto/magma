defmodule Magma.CLI do
  @moduledoc "Main entry point for the Magma CLI."

  alias Magma.CLI.Command
  alias Magma.CLI.IO, as: CLI

  @commands [
              Command.Init,
              Command.Help,
              Command.Version,
              Command.CopyPrompt,
              Command.ImportSession,
              Command.ExecPrompt
            ]
            |> Map.new(&{&1.name(), &1})

  @doc "Returns the map of registered commands."
  def commands, do: @commands

  @doc "Returns the application version."
  def version, do: Application.spec(:magma, :vsn) |> to_string()

  @doc "Main entry point for Burrito."
  def main do
    Burrito.Util.Args.argv()
    |> run()
    |> System.stop()
  end

  @doc "Runs the CLI with the given arguments."
  def run([]), do: Command.Help.run([]) |> exit_code()

  def run([command_name | args]) do
    case @commands[command_name] do
      nil ->
        {:error, "Unknown command: #{command_name}. Run 'magma help' for available commands."}

      command_module ->
        command_module.run(args)
    end
    |> exit_code()
  end

  defp exit_code(:ok), do: 0
  defp exit_code({:ok, _}), do: 0

  defp exit_code({:error, error}) do
    CLI.error(to_string(error))
    1
  end

  defp exit_code(:abort), do: :abort
end

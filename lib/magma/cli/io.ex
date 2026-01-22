defmodule Magma.CLI.IO do
  @moduledoc """
  CLI I/O abstraction replacing Mix.shell() functions.

  Provides colored terminal output and user prompts without
  depending on Mix infrastructure.
  """

  @doc """
  Prints an info message with green "* " prefix.

  Output is suppressed in test environment by default.
  This can be overridden with `config :magma, quiet: false`.
  """
  def info(message) when is_binary(message) do
    unless quiet?() do
      IO.puts(IO.ANSI.format([:green, "* ", :reset, message]))
    end
  end

  def info(ansi_data) when is_list(ansi_data) do
    unless quiet?() do
      IO.puts(IO.ANSI.format(ansi_data))
    end
  end

  @doc """
  Prints an error message in red to stderr.
  """
  def error(message) do
    IO.puts(:stderr, IO.ANSI.format([:red, to_string(message), :reset]))
  end

  @doc """
  Prompts the user for input and returns the trimmed response.

  In test mode:
  - Sends `{:shell, :prompt, [message]}` to calling process
  - Checks for `{:shell_input, :prompt, response}` message for mocked input
  """
  if Mix.env() == :test do
    def prompt(message) do
      send(self(), {:shell, :prompt, [message]})

      receive do
        {:shell_input, :prompt, response} -> response
      after
        0 -> do_prompt(message)
      end
    end
  else
    def prompt(message) do
      do_prompt(message)
    end
  end

  defp do_prompt(message) do
    message
    |> IO.gets()
    |> String.trim()
  end

  @doc """
  Asks a yes/no question. Returns true for "y", "Y", or empty input.

  In test mode:
  - Sends `{:shell, :yes?, [message]}` to calling process
  - Checks for `{:shell_input, :yes?, response}` message for mocked input
  """
  if Mix.env() == :test do
    def yes?(message) do
      send(self(), {:shell, :yes?, [message]})

      receive do
        {:shell_input, :yes?, response} -> response
      after
        0 -> do_yes?(message)
      end
    end
  else
    def yes?(message) do
      do_yes?(message)
    end
  end

  defp do_yes?(message) do
    response =
      (message <> " [Yn] ")
      |> IO.gets()
      |> String.trim()
      |> String.downcase()

    response == "" or response == "y"
  end

  defp test_mode? do
    Application.get_env(:magma, :env) == :test
  end

  defp quiet? do
    Application.get_env(:magma, :quiet, test_mode?())
  end
end

defmodule Magma.CLI.Helper do
  @moduledoc """
  Helper functions for CLI tasks.
  """

  @doc """
  Parses command line arguments and calls the given function on success.

  On invalid options, prints an error and exits.
  """
  def with_valid_options(args, options_spec, fun) do
    case OptionParser.parse(args, strict: options_spec) do
      {opts, remaining, []} ->
        fun.(opts, remaining)

      {_opts, _remaining, invalid} ->
        """
        Invalid args: #{inspect(invalid)}

        Available options:

        #{Enum.map(options_spec, fn {opt, type} -> "- #{opt} : #{type}\n" end)}
        """
        |> abort()

      undefined ->
        raise "Undefined result: #{inspect(undefined)}"
    end
  end

  @doc """
  Prints an error message and exits with status 1.
  """
  def abort(message) do
    Magma.CLI.IO.error(message)
    exit({:shutdown, 1})
  end

  @doc """
  Handles ok/error tuples, aborting on error.
  """
  def handle_error({:ok, _}), do: :ok
  def handle_error(:ok), do: :ok
  def handle_error({:error, error}), do: error |> to_string() |> abort()
end

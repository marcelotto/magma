defmodule Magma.CLI.Helper do
  @moduledoc """
  Helper functions for CLI commands.
  """

  @doc """
  Parses command line arguments and calls the given function on success.

  Returns `{:error, message}` on invalid options.
  """
  def with_valid_options(args, options_spec, fun) do
    case OptionParser.parse(args, strict: options_spec) do
      {opts, remaining, []} ->
        fun.(opts, remaining)

      {_opts, _remaining, invalid} ->
        {:error,
         """
         Invalid args: #{inspect(invalid)}

         Available options:

         #{Enum.map(options_spec, fn {opt, type} -> "- #{opt} : #{type}\n" end)}\
         """}

      undefined ->
        raise "Undefined result: #{inspect(undefined)}"
    end
  end

  @doc """
  Handles result tuples for Mix tasks.

  Raises on error, returns `:ok` on success.
  """
  def handle_mix_result(:ok), do: :ok
  def handle_mix_result({:ok, _}), do: :ok
  def handle_mix_result({:error, error}), do: Mix.raise(to_string(error))
end

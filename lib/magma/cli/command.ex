defmodule Magma.CLI.Command do
  @moduledoc "Behaviour for CLI commands"

  @type args :: [String.t()]

  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback run(args()) :: :ok | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Magma.CLI.Command
      import Magma.CLI.Helper
    end
  end
end

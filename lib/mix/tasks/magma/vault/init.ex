defmodule Mix.Tasks.Magma.Vault.Init do
  @shortdoc "Initializes the Magma vault directory"
  @moduledoc @shortdoc

  use Mix.Task

  alias Magma.Vault.Initializer

  @options [
    base_vault: :string
  ]

  def run(args) do
    case OptionParser.parse(args, strict: @options) do
      {opts, remaining, []} ->
        opts
        |> Keyword.get(:base_vault)
        |> Initializer.initialize(remaining)

      {_opts, _remaining, invalid} ->
        """
        Invalid args: #{inspect(invalid)}

        Available options:

        #{Enum.map(@options, fn {opt, type} -> "- #{opt} : #{type}\n" end)}
        """
        |> Mix.shell().error()

      undefined ->
        raise "Undefined error: #{undefined}"
    end
  end
end

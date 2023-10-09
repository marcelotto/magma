defmodule Mix.Tasks.Magma.Text.New do
  @shortdoc "Generates a new text concept"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Text

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("text_type and/or name missing")

      _opts, [text_type_name, text_name] ->
        case Text.create(text_name, text_type_name) do
          {:ok, _} -> :ok
          {:error, error} -> raise error
        end
    end)
  end
end

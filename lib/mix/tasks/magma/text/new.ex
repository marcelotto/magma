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
      _opts, [] -> Mix.shell().error("text name missing")
      _opts, [text_name] -> create(text_name)
      _opts, [text_name, text_type_name] -> create(text_name, text_type_name)
    end)
  end

  defp create(text_name, text_type \\ nil) do
    case Text.create(text_name, text_type) do
      {:ok, _} -> :ok
      {:error, error} -> raise error
    end
  end
end

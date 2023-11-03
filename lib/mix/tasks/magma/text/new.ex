defmodule Mix.Tasks.Magma.Text.New do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Text

  @shortdoc "Generates a new text concept"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> error("text name missing")
      _opts, [text_name] -> create(text_name)
      _opts, [text_name, text_type_name] -> create(text_name, text_type_name)
    end)
  end

  defp create(text_name, text_type \\ nil) do
    text_name
    |> Text.create(text_type)
    |> handle_error()
  end
end

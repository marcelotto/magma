defmodule Mix.Tasks.Magma.Text.Type.New do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  @shortdoc "Generates a new text type"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("text type name missing")

      _opts, [text_type_name] ->
        Magma.Config.TextType.create(text_type_name)

      _opts, [text_type_name, text_type_label] ->
        Magma.Config.TextType.create(text_type_name, label: text_type_label)
    end)
    |> handle_error()
  end
end

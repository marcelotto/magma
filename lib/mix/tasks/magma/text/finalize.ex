defmodule Mix.Tasks.Magma.Text.Finalize do
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Artefact
  alias Magma.Text.Preview

  @shortdoc "Generates the final text from a given preview document"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("preview document name missing")

      _opts, [preview_name] ->
        with {:ok, preview} <- Preview.load(preview_name),
             {:ok, %Artefact.Version{}} <- Artefact.Version.create(preview, [], force: true) do
          :ok
        else
          error -> handle_error(error)
        end
    end)
  end
end

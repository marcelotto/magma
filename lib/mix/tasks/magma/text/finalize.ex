defmodule Mix.Tasks.Magma.Text.Finalize do
  @shortdoc "Generates the final text from a given preview document"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.Artefact
  alias Magma.Text.Preview

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("preview document name missing")

      _opts, [preview_name] ->
        preview_name
        |> Preview.load!()
        |> Artefact.Version.create([], force: true)
        |> case do
          {:ok, %Artefact.Version{}} -> :ok
          {:error, error} -> raise error
        end
    end)
  end
end

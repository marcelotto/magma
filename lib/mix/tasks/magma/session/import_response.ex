defmodule Mix.Tasks.Magma.Session.ImportResponse do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.Session

  @shortdoc "Imports the latest response file into the session document"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("session name or path missing")

      _opts, [session_name] ->
        session_name
        |> Session.import_response()
        |> handle_error()
    end)
  end
end

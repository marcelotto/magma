defmodule Magma.CLI.Command.ImportSession do
  use Magma.CLI.Command

  alias Magma.Session

  @impl true
  def name, do: "import-session"

  @impl true
  def description, do: "Import latest response file into session document"

  @impl true
  def run(args) do
    with_valid_options(args, [], fn
      _opts, [] -> {:error, "session name or path missing"}
      _opts, [session_name] -> Session.import_response(session_name)
    end)
  end
end

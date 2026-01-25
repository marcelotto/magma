defmodule Magma.Generation.Manual do
  use Magma.Generation

  alias Magma.Prompt.Assembler
  alias Magma.CLI.IO, as: CLI

  import Magma.Utils.Guards

  defstruct []

  require Logger

  def new(description \\ nil) do
    {:ok, struct(__MODULE__, description: description)}
  end

  def new!(description \\ nil) do
    case new(description) do
      {:ok, manual} -> manual
    end
  end

  @impl true
  def execute(%__MODULE__{}, prompt, opts \\ []) when is_prompt(prompt) do
    with {:ok, _} <- Assembler.copy_to_clipboard(prompt) do
      if Keyword.get(opts, :interactive, true) do
        {:ok, result_from_user()}
      else
        {:ok, ""}
      end
    end
  end

  defp result_from_user do
    """
    The prompt was copied to the clipboard.
    Please paste back the result of the manual execution and press Enter:
    """
    |> CLI.prompt()
  end
end

defmodule Magma.Generation.Manual do
  @behaviour Magma.Generation

  alias Magma.Artefact

  defstruct []

  require Logger

  def new(description \\ nil) do
    {:ok, struct(__MODULE__, description: description)}
  end

  def new!(description \\ nil) do
    case new(description) do
      {:ok, manual} -> manual
      {:error, error} -> raise error
    end
  end

  @impl true
  def execute(%__MODULE__{}, %Artefact.Prompt{} = prompt, opts \\ []) do
    Artefact.Prompt.copy_to_clipboard(prompt)

    if Keyword.get(opts, :interactive, true) do
      {:ok, result_from_user()}
    else
      {:ok, ""}
    end
  end

  defp result_from_user do
    """
    The prompt was copied to the clipboard.
    Please paste back the result of the manual execution and press Enter:
    """
    |> Mix.shell().prompt()
  end
end
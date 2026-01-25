defmodule Mix.Tasks.Magma.Artefact.SelectDraft do
  @moduledoc """
  Selects a prompt result as a draft version.

      $ mix magma.artefact.select_draft "Name of prompt result"
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.{Artefact, PromptResult}

  @shortdoc "Selects a prompt result as a draft version"

  @options []

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        {:error, "prompt result name or path missing"}

      _opts, [prompt_result_name] ->
        with {:ok, prompt_result} <- PromptResult.load(prompt_result_name),
             {:ok, _} <- Artefact.Version.create(prompt_result) do
          :ok
        end
    end)
    |> handle_mix_result()
  end
end

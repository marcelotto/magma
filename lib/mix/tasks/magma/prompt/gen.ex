defmodule Mix.Tasks.Magma.Prompt.Gen do
  @moduledoc """
  Generates a custom prompt or an artefact prompt document.

  For a custom prompt document, provide the prompt name as the only argument:

      $ mix magma.prompt.gen "Prompt for something"

  For an artefact prompt document, provide the concept name and artefact type:

      $ mix magma.prompt.gen "Some.Module" ModuleDoc

  Note that artefact prompts are already created when a concept document is created.
  Use `mix magma.prompt.update` to regenerate an existing artefact prompt.

  ## Options

  - `--force` - Overwrite existing documents without confirmation
  """

  use Mix.Task

  import Magma.CLI.Helper

  alias Magma.{Artefact, Prompt, Concept}

  @shortdoc "Generates a custom prompt or artefact prompt document"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        {:error, "artefact type missing"}

      _opts, [concept_name, artefact_type] ->
        if artefact_module = Artefact.type(artefact_type) do
          with {:ok, concept} <- Concept.load(concept_name),
               {:ok, _} <- Artefact.Prompt.create(concept, artefact_module) do
            :ok
          end
        else
          {:error, "unknown artefact type: #{artefact_type}"}
        end

      _opts, [prompt_name] ->
        Prompt.create(prompt_name)
    end)
    |> handle_mix_result()
  end
end

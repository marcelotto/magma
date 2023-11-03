defmodule Mix.Tasks.Magma.Prompt.Gen do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Prompt, Concept}

  @shortdoc "Generates a custom prompt or artefact prompt document"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        error("artefact type missing")

      _opts, [concept_name, artefact_type] ->
        if artefact_module = Artefact.type(artefact_type) do
          with {:ok, concept} <- Concept.load(concept_name),
               {:ok, _} <- Artefact.Prompt.create(concept, artefact_module) do
            :ok
          else
            error -> handle_error(error)
          end
        else
          error("unknown artefact type: #{artefact_type}")
        end

      _opts, [prompt_name] ->
        Prompt.create(prompt_name)
        |> handle_error()
    end)
  end
end

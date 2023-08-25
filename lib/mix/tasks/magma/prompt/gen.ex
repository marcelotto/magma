defmodule Mix.Tasks.Magma.Prompt.Gen do
  @shortdoc "Generates a prompt"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Concept}

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("artefact type missing")

      _opts, [concept_name, artefact_type] ->
        if artefact_module = Artefact.type(artefact_type) do
          with {:ok, concept} <- Concept.load(concept_name),
               {:ok, artefact} <- artefact_module.new(concept),
               {:ok, prompt} <- Artefact.Prompt.new(artefact) do
            Artefact.Prompt.create(prompt)
          else
            {:error, error} -> raise error
          end
        else
          raise "unknown artefact type: #{artefact_type}"
        end
    end)
  end
end

defmodule Mix.Tasks.Magma.Prompt.Gen do
  @shortdoc "Generates a prompt"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Prompt, Concept}

  @options []

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] ->
        Mix.shell().error("artefact type missing")

      _opts, [concept_name, artefact_type] ->
        if artefact_module = Artefact.type(artefact_type) do
          with {:ok, concept} <- Concept.load(concept_name) do
            Artefact.Prompt.create(concept, artefact_module)
            |> ok_or_fail!()
          else
            {:error, error} -> raise error
          end
        else
          raise "unknown artefact type: #{artefact_type}"
        end

      _opts, [prompt_name] ->
        Prompt.create(prompt_name)
        |> ok_or_fail!()
    end)
  end

  defp ok_or_fail!({:ok, _}), do: :ok
  defp ok_or_fail!({:error, error}), do: raise(error)
end

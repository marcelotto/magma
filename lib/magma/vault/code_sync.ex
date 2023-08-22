defmodule Magma.Vault.CodeSync do
  alias Magma.Matter.Project
  alias Magma.{Vault, Concept, Artefact, Artefacts}

  def sync(_opts \\ []) do
    if File.exists?(Vault.path()) do
      Enum.each(Project.modules(), fn module ->
        with {:ok, concept} <- Concept.new(module),
             {:ok, concept} <- Concept.create(concept) do
          create_artefact_prompts(concept)
        end
      end)

      :ok
    else
      {:error, :vault_not_existing}
    end
  end

  defp create_artefact_prompts(concept) do
    with {:ok, artefact} <- Artefacts.ModuleDoc.new(concept),
         {:ok, prompt} <- Artefact.Prompt.new(artefact) do
      Artefact.Prompt.create(prompt)
    end
  end
end

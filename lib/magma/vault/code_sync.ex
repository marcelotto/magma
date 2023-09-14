defmodule Magma.Vault.CodeSync do
  alias Magma.Matter.Project
  alias Magma.{Vault, Concept, Artefact, Artefacts}

  def sync(_opts \\ []) do
    if File.exists?(Vault.path()) do
      Enum.each(Project.modules(), fn module_matter ->
        with {:ok, concept} <- Concept.create(module_matter) do
          create_artefact_prompts(concept)
        end
      end)

      :ok
    else
      {:error, :vault_not_existing}
    end
  end

  defp create_artefact_prompts(concept) do
    with {:ok, artefact} <- Artefacts.ModuleDoc.new(concept) do
      Artefact.Prompt.create(artefact)
    end
  end
end

defmodule Magma.Vault.CodeSync do
  alias Magma.Matter.Project
  alias Magma.{Vault, Concept, Artefacts}

  import Magma.Utils

  def sync(_opts \\ []) do
    if File.exists?(Vault.path()) do
      # We must create all concepts first, since the moduledoc prompts require this to determine submodules (see Magma.Matter.Module.submodules/1)
      with {:ok, concepts} <- map_while_ok(Project.modules(), &Concept.create/1),
           {:ok, _} <- map_while_ok(concepts, &create_artefact_prompts/1) do
        :ok
      end
    else
      {:error, :vault_not_existing}
    end
  end

  defp create_artefact_prompts(concept) do
    Artefacts.ModuleDoc.create_prompt(concept)
  end
end

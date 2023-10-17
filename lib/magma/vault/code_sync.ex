defmodule Magma.Vault.CodeSync do
  @moduledoc false

  alias Magma.Matter.Project
  alias Magma.{Vault, Concept}

  import Magma.Utils

  def sync(_opts \\ []) do
    if File.exists?(Vault.path()) do
      # We must create all concepts first, since the moduledoc prompts require this to determine submodules (see Magma.Matter.Module.submodules/1)
      with {:ok, concepts} <-
             map_while_ok(Project.modules(), &Concept.create(&1, [], prompts: false)),
           {:ok, _} <- flat_map_while_ok(concepts, &Concept.create_prompts/1) do
        :ok
      end
    else
      {:error, :vault_not_existing}
    end
  end
end

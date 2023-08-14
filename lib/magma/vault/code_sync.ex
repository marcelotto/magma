defmodule Magma.Vault.CodeSync do
  alias Magma.Vault
  alias Magma.Matter.Project
  alias Magma.Concept

  def sync(_opts \\ []) do
    if File.exists?(Vault.path()) do
      for module <- Project.modules() do
        module
        |> Concept.new!()
        |> Concept.create()
      end

      :ok
    else
      {:error, :vault_not_existing}
    end
  end
end

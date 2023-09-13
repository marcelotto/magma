defmodule Magma.Vault.CodeSyncTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault.CodeSync

  alias Magma.Vault.CodeSync
  alias Magma.{Matter, Concept, Artefact, Artefacts}

  describe "sync/0" do
    test "creates concepts and moduledoc for the modules when they don't exist yet" do
      Vault.create("Magma-Project", :default, code_sync: false)

      assert CodeSync.sync() == :ok

      [
        Magma,
        Magma.Vault,
        Magma.Concept,
        Magma.Vault.CodeSync
      ]
      |> Enum.each(fn module ->
        assert {:ok, %Concept{} = concept} =
                 module
                 |> Matter.Module.new!()
                 |> Concept.new!()
                 |> Concept.load()

        assert {:ok, %Artefact.Prompt{}} =
                 concept
                 |> Artefacts.ModuleDoc.new!()
                 |> Artefact.Prompt.new!()
                 |> Artefact.Prompt.load()
      end)
    end

    test "when the vault not exists" do
      assert CodeSync.sync() == {:error, :vault_not_existing}
    end
  end
end

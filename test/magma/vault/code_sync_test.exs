defmodule Magma.Vault.CodeSyncTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault.CodeSync

  alias Magma.Vault.CodeSync
  alias Magma.{Matter, Concept, Artefact, Artefacts}

  describe "sync/0" do
    @tag vault_files: [
           "concepts/modules/Nested/Nested.Example.md",
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/Project.md"
         ]
    test "creates concepts and moduledoc for the modules when they don't exist yet" do
      original_concept = Concept.load!("Nested.Example")
      original_prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

      Vault.create("Magma-Project", :default, code_sync: false)

      assert CodeSync.sync() == :ok

      [
        Magma,
        Magma.Vault,
        Magma.Concept,
        Magma.DocumentStruct.Section
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

      # test that existing files are not overwritten
      assert Concept.load!("Nested.Example") == original_concept
      assert Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example") == original_prompt

      # test that private modules are ignored
      concept =
        Magma.DocumentStruct.Parser
        |> Matter.Module.new!()
        |> Concept.new!()

      refute File.exists?(concept.path)
    end
  end
end

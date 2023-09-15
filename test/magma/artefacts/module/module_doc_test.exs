defmodule Magma.Artefacts.ModuleDocTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.ModuleDoc

  alias Magma.Artefact
  alias Magma.Artefacts.ModuleDoc

  describe "prompt/1" do
    test "with matching matter type" do
      module_concept = module_concept()

      assert {:ok,
              %Artefact.Prompt{
                artefact: ModuleDoc,
                concept: ^module_concept
              }} = ModuleDoc.prompt(module_concept)
    end

    test "with non-matching matter type" do
      assert_raise FunctionClauseError, fn ->
        ModuleDoc.prompt(project_concept())
      end
    end
  end

  test "version_path/1" do
    assert ModuleDoc.version_path(TopLevelExample) ==
             abs_path(
               "test/data/example_vault/artefacts/final/modules/TopLevelExample/ModuleDoc of TopLevelExample.md"
             )

    assert ModuleDoc.version_path(Nested.Example) ==
             abs_path(
               "test/data/example_vault/artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md"
             )
  end

  describe "get/1" do
    @tag vault_files: [
           "artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md",
           "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md",
           "artefacts/final/modules/TopLevelExample/ModuleDoc of TopLevelExample.md",
           "artefacts/generated/modules/TopLevelExample/__prompt_results__/Generated ModuleDoc of TopLevelExample (2023-09-07T21:17:00).md",
           "artefacts/generated/modules/TopLevelExample/Prompt for ModuleDoc of TopLevelExample.md",
           "concepts/modules/TopLevelExample.md"
         ]
    test "when an artefact version exists" do
      assert ModuleDoc.get(Nested.Example) ==
               "The final documentation of `Nested.Example`."

      assert ModuleDoc.get(TopLevelExample) ==
               "A test module."
    end

    test "when an artefact version it does not exists" do
      refute ModuleDoc.get(NotExisting)
    end
  end
end

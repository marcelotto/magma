defmodule Magma.Artefacts.ModuleDocTest do
  use Magma.TestCase

  doctest Magma.Artefacts.ModuleDoc

  alias Magma.Artefacts.ModuleDoc

  describe "new/1" do
    test "with matching matter type" do
      module_concept = module_concept()

      assert ModuleDoc.new(module_concept) ==
               {:ok,
                %ModuleDoc{
                  concept: module_concept,
                  name: "ModuleDoc of #{module_concept.name}"
                }}
    end

    test "with non-matching matter type" do
      assert_raise FunctionClauseError, fn ->
        ModuleDoc.new(project_concept())
      end
    end
  end
end

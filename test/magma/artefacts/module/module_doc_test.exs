defmodule Magma.Artefacts.ModuleDocTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.ModuleDoc

  alias Magma.{Artefacts, Artefact, Concept}

  describe "new/1" do
    test "with matching matter type" do
      module_concept = module_concept()

      assert Artefacts.ModuleDoc.new(module_concept) ==
               {:ok,
                %Artefacts.ModuleDoc{
                  concept: module_concept,
                  name: "ModuleDoc of #{module_concept.name}"
                }}
    end

    test "with non-matching matter type" do
      assert_raise FunctionClauseError, fn ->
        Artefacts.ModuleDoc.new(project_concept())
      end
    end
  end

  describe "Artefact.Prompt.create/1" do
    @tag vault_files: "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
    test "moduledoc" do
      module_concept = module_concept(Some.DocumentWithFrontMatter) |> Concept.load!()
      artefact = Artefacts.ModuleDoc.new!(module_concept)
      prompt = Artefact.Prompt.new!(artefact)

      assert {:ok,
              %Artefact.Prompt{
                artefact: ^artefact,
                name: name,
                tags: ["magma-vault"],
                aliases: [],
                created_at: created_at,
                custom_metadata: %{}
              }} = Artefact.Prompt.create(prompt)

      assert name == "Prompt for #{artefact.name}"
      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2
    end
  end
end

defmodule Magma.Artefact.VersionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.Version

  alias Magma.{Artefact, PromptResult}
  alias Magma.Artefacts.ModuleDoc

  # integration tests of artefact version documents for concrete artefacts
  # can be found as part of the respective artefact tests

  describe "new/1" do
    test "with missing prompt result" do
      artefact = module_doc_artefact()

      missing_prompt_result =
        %Magma.DocumentNotFound{
          name: "Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00)",
          document_type: PromptResult
        }

      assert {:ok,
              %Artefact.Version{
                draft: ^missing_prompt_result,
                artefact: ^artefact,
                tags: nil,
                aliases: nil,
                created_at: nil,
                content: nil
              } = version} =
               Artefact.Version.new(missing_prompt_result,
                 concept: artefact.concept,
                 artefact: artefact
               )

      assert version.name == "ModuleDoc of Nested.Example"

      assert version.path ==
               Vault.path("artefacts/final/modules/Nested/Example/#{version.name}.md")
    end
  end

  describe "load/1" do
    @tag vault_files: [
           "artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "without PromptResult" do
      assert {:ok,
              %Artefact.Version{
                artefact: %ModuleDoc{name: "ModuleDoc of Nested.Example"},
                draft: %Magma.DocumentNotFound{
                  name: "Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00)"
                }
              }} = Artefact.Version.load("ModuleDoc of Nested.Example")
    end
  end
end

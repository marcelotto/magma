defmodule Magma.Artefact.VersionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.Version

  alias Magma.Artefact

  describe "new/1" do
    test "with ModuleDoc artefact" do
      prompt_result = module_doc_artefact_prompt_result()

      assert {:ok,
              %Artefact.Version{
                prompt_result: ^prompt_result,
                tags: nil,
                aliases: nil,
                created_at: nil,
                custom_metadata: nil,
                content: nil
              } = version} = Artefact.Version.new(prompt_result)

      assert version.name == "ModuleDoc of Nested.Example"

      assert version.path ==
               Vault.path("artefacts/final/modules/Nested/Example/#{version.name}.md")
    end
  end

  describe "create/1" do
    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "moduledoc", %{vault_files: [prompt_result_file | _]} do
      prompt_result =
        prompt_result_file
        |> Vault.path()
        |> Artefact.PromptResult.load!()

      assert {:ok,
              %Artefact.Version{
                prompt_result: ^prompt_result,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(prompt_result)

      assert version.name == "ModuleDoc of Nested.Example"

      assert version.content ==
               """
               # #{version.name}

               The final documentation of `Nested.Example`.

               """

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2
    end
  end
end

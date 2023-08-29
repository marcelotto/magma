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
                path: path,
                name: name,
                tags: nil,
                aliases: nil,
                created_at: nil,
                custom_metadata: nil,
                content: nil
              }} = Artefact.Version.new(prompt_result)

      assert name == "ModuleDoc of Nested.Example"

      assert path == Vault.path("__artefacts__/modules/Nested.Example/moduledoc/#{name}.md")
    end
  end

  describe "create/1" do
    @tag vault_files: [
           "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/prompt_results/Generated ModuleDoc of Some.DocumentWithFrontMatter (2023-08-23T12:53:00).md",
           "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md",
           "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
         ]
    test "moduledoc", %{vault_files: [prompt_result_file | _]} do
      prompt_result =
        prompt_result_file
        |> Vault.path()
        |> Artefact.PromptResult.load!()

      version = Artefact.Version.new!(prompt_result)

      assert {:ok,
              %Artefact.Version{
                prompt_result: ^prompt_result,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(version)

      assert version.name == "ModuleDoc of Some.DocumentWithFrontMatter"

      assert version.content ==
               """
               # #{version.name}

               The final documentation of `Some.DocumentWithFrontMatter`.
               """

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2
    end
  end
end

defmodule Magma.Artefact.VersionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.Version

  alias Magma.{Artefact, Concept, PromptResult}
  alias Magma.Artefacts.{ModuleDoc, Article}
  alias Magma.Text.Preview

  import Magma.Obsidian.View.Helper
  import ExUnit.CaptureLog

  describe "new/1" do
    test "ModuleDoc artefact" do
      prompt_result = module_doc_artefact_prompt_result()
      concept = prompt_result.prompt.concept

      assert {:ok,
              %Artefact.Version{
                draft: ^prompt_result,
                concept: ^concept,
                artefact: ModuleDoc,
                tags: nil,
                aliases: nil,
                created_at: nil,
                content: nil
              } = version} = Artefact.Version.new(prompt_result)

      assert version.name == "ModuleDoc of Nested.Example"

      assert version.path ==
               Vault.path("artefacts/final/modules/Nested/Example/#{version.name}.md")
    end

    test "with missing prompt result" do
      concept = module_concept()

      missing_prompt_result =
        %Magma.DocumentNotFound{
          name: "Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00)",
          document_type: PromptResult
        }

      assert {:ok,
              %Artefact.Version{
                draft: ^missing_prompt_result,
                concept: ^concept,
                artefact: ModuleDoc,
                tags: nil,
                aliases: nil,
                created_at: nil,
                content: nil
              } = version} =
               Artefact.Version.new(missing_prompt_result, concept: concept, artefact: ModuleDoc)

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
                artefact: ModuleDoc,
                draft: %Magma.DocumentNotFound{
                  name: "Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00)"
                }
              }} = Artefact.Version.load("ModuleDoc of Nested.Example")
    end
  end

  describe "create/1 (and re-load/1)" do
    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "ModuleDoc artefact", %{vault_files: [prompt_result_file | _]} do
      prompt_result =
        prompt_result_file
        |> Vault.path()
        |> PromptResult.load!()

      assert {:ok,
              %Artefact.Version{
                draft: ^prompt_result,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(prompt_result)

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2

      assert version.name == "ModuleDoc of Nested.Example"

      assert version.content ==
               """
               >[!caution]
               >Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
               >
               >Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

               # #{version.name}

               ## #{ModuleDoc.prompt_result_section_title()}

               The final documentation of `Nested.Example`.
               """

      assert Artefact.Version.load(version.path) == {:ok, version}
    end

    @tag vault_files: [
           "artefacts/generated/texts/Some User Guide/__prompt_results__/Generated Some User Guide ToC (2023-09-18T12:56:00).md",
           "artefacts/generated/texts/Some User Guide/Prompt for Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "TableOfContents artefact", %{vault_files: [prompt_result_file | _]} do
      prompt_result =
        prompt_result_file
        |> Vault.path()
        |> PromptResult.load!()

      assert {:ok,
              %Artefact.Version{
                draft: ^prompt_result,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(prompt_result)

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2

      assert version.name == "Some User Guide ToC"

      assert version.path ==
               Vault.path("artefacts/final/texts/Some User Guide/#{version.name}.md")

      assert version.content ==
               """
               #{button("Assemble sections", "magma.text.assemble", color: "blue")}

               # #{version.name}

               ## Introduction

               Abstract: Abstract of the introduction.

               ## Next section

               Abstract: Abstract of the next section.

               ## Another section

               Abstract: Abstract of the another section.
               """

      assert Artefact.Version.load(version.path) == {:ok, version}
    end

    @tag vault_files: [
           "artefacts/generated/texts/Some User Guide/article/__prompt_results__/Generated Some User Guide - Introduction (article section) (2023-09-23T00:08:00).md",
           "artefacts/generated/texts/Some User Guide/article/Prompt for Some User Guide - Introduction (article section).md",
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "Section artefact", %{vault_files: [prompt_result_file | _]} do
      prompt_result =
        prompt_result_file
        |> Vault.path()
        |> PromptResult.load!()

      assert {:ok,
              %Artefact.Version{
                draft: ^prompt_result,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(prompt_result)

      assert version.name == "Some User Guide - Introduction (article section)"

      assert version.path ==
               Vault.path("artefacts/final/texts/Some User Guide/article/#{version.name}.md")

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2

      assert version.content ==
               """
               # #{version.name}

               The content of the generated introduction section.
               """

      assert Artefact.Version.load(version.path) == {:ok, version}
    end

    @tag vault_files: [
           "concepts/texts/Some User Guide/Some User Guide.md",
           "artefacts/generated/texts/Some User Guide/__previews__/Some User Guide (article) Preview.md",
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Next section (article section).md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Another section (article section).md",
           "concepts/Project.md"
         ]
    test "Article artefact (from Preview)" do
      "Some User Guide ToC"
      |> Artefact.Version.load!()
      |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

      preview = Preview.load!("Some User Guide (article) Preview")
      concept = Concept.load!("Some User Guide")

      assert {:ok,
              %Artefact.Version{
                concept: ^concept,
                artefact: Article,
                draft: ^preview,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = version} = Artefact.Version.create(preview)

      assert version.name == "Some User Guide (article)"

      assert version.path ==
               Vault.path("artefacts/final/texts/Some User Guide/#{version.name}.md")

      assert version.content ==
               """
               # Some User Guide (article) Preview

               ## Introduction

               The content of the final introduction section.

               ## Next section

               The content of the final next section.

               ## Another section

               The content of another final section.
               """

      assert DateTime.diff(DateTime.utc_now(), version.created_at, :second) <= 2

      assert Artefact.Version.load(version.path) == {:ok, version}
    end

    @tag vault_files: [
           "concepts/texts/Some User Guide/Some User Guide.md",
           "artefacts/generated/texts/Some User Guide/__previews__/Some User Guide (article) Preview.md",
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Another section (article section).md",
           "concepts/Project.md"
         ]
    test "from preview when section artefact versions are missing" do
      "Some User Guide ToC"
      |> Artefact.Version.load!()
      |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

      preview = Preview.load!("Some User Guide (article) Preview")

      assert capture_log(fn ->
               assert {:ok, _} = Artefact.Version.create(preview)
             end) =~
               "failed to load [[Some User Guide - Next section (article section)]] during resolution"

      version = Artefact.Version.load!("Some User Guide (article)")

      assert version.content ==
               """
               # Some User Guide (article) Preview

               ## Introduction

               The content of the final introduction section.

               ## Next section ![[Some User Guide - Next section (article section)#Some User Guide - Next section (article section)|]]

               ## Another section

               The content of another final section.
               """
    end
  end
end

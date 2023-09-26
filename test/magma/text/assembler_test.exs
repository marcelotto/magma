defmodule Magma.Text.AssemblerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Text.Assembler

  alias Magma.Text.Assembler
  alias Magma.{Artefact, Concept}

  describe "assemble/1" do
    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/Project.md"
         ]
    test "UserGuide" do
      version = Artefact.Version.load!("Some User Guide ToC")

      sections = [
        "Some User Guide - Introduction",
        "Some User Guide - Next section",
        "Some User Guide - Another section"
      ]

      [section1_path, section2_path, section3_path] =
        Enum.map(sections, &TestVault.path("concepts/texts/Some User Guide/#{&1}.md"))

      [section1_prompt_path, section2_prompt_path, section3_prompt_path] =
        Enum.map(
          sections,
          &TestVault.path(
            "artefacts/generated/texts/Some User Guide/article/Prompt for '#{&1}' article section.md"
          )
        )

      # check that sections concepts do not exist already
      refute Vault.document_path(section1_path)
      refute Vault.document_path(section2_path)
      refute Vault.document_path(section3_path)

      # check that section prompt do not exist already
      refute Vault.document_path(section1_prompt_path)
      refute Vault.document_path(section2_prompt_path)
      refute Vault.document_path(section3_prompt_path)

      assert {:ok, %Concept{} = updated_text_concept} =
               Assembler.assemble(version)

      # check that the updated concept was saved
      assert Concept.load(updated_text_concept.path) == {:ok, updated_text_concept}

      # check that only the content was changed
      assert %Concept{updated_text_concept | content: nil, sections: nil} ==
               %Concept{Concept.load!("Some User Guide") | content: nil, sections: nil}

      # check that all section transclusions were added
      assert String.contains?(
               updated_text_concept.content,
               "![[#{Path.basename(section1_path, ".md")}"
             )

      assert String.contains?(
               updated_text_concept.content,
               "![[#{Path.basename(section2_path, ".md")}"
             )

      assert String.contains?(
               updated_text_concept.content,
               "![[#{Path.basename(section3_path, ".md")}"
             )

      # check that all section concepts were created
      assert {:ok, %Concept{}} = Concept.load(section1_path)
      assert {:ok, %Concept{}} = Concept.load(section2_path)
      assert {:ok, %Concept{}} = Concept.load(section3_path)

      # check that section prompts were created
      assert {:ok, %Artefact.Prompt{}} = Artefact.Prompt.load(section1_prompt_path)
      assert {:ok, %Artefact.Prompt{}} = Artefact.Prompt.load(section2_prompt_path)
      assert {:ok, %Artefact.Prompt{}} = Artefact.Prompt.load(section3_prompt_path)

      # check that artefact previews were created
      assert Vault.document_path("'Some User Guide' article preview")
    end
  end
end

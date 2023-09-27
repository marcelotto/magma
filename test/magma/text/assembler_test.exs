defmodule Magma.Text.AssemblerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Text.Assembler

  alias Magma.Text.Assembler
  alias Magma.{Artefact, Concept}
  alias Magma.Artefacts.TableOfContents

  describe "assemble/1" do
    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/Project.md"
         ]
    test "UserGuide" do
      toc_version = Artefact.Version.load!("Some User Guide ToC")

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
               Assembler.assemble(toc_version)

      # check that the updated concept was saved
      assert Concept.load(updated_text_concept.path) == {:ok, updated_text_concept}

      # check that only the content was changed
      assert %Concept{updated_text_concept | content: nil, sections: nil} ==
               %Concept{Concept.load!("Some User Guide") | content: nil, sections: nil}

      # check that the 'Assemble' button in the preview was replaced with callout
      updated_toc_version = Artefact.Version.load!("Some User Guide ToC")
      refute updated_toc_version.content |> String.contains?(TableOfContents.assemble_button())

      assert updated_toc_version.content
             |> String.contains?(TableOfContents.assemble_callout(updated_toc_version))

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

    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/Project.md"
         ]
    test "when concepts are already present and force: true is set" do
      version = Artefact.Version.load!("Some User Guide ToC")

      assert {:ok, %Concept{}} = Assembler.assemble(version, force: true)
    end

    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/Project.md"
         ]
    test "when concepts are already present and not overwritten" do
      version = Artefact.Version.load!("Some User Guide ToC")

      send(self(), {:mix_shell_input, :yes?, false})

      assert {:ok, %Concept{}} = Assembler.assemble(version)

      assert_receive {:mix_shell, :yes?, [_]}
    end

    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "artefacts/generated/texts/Some User Guide/__previews__/'Some User Guide' article preview.md",
           "artefacts/generated/texts/Some User Guide/article/Prompt for 'Some User Guide - Introduction' article section.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/Project.md"
         ]
    test "when prompts or preview are already present" do
      version = Artefact.Version.load!("Some User Guide ToC")

      assert {:ok, %Concept{}} = Assembler.assemble(version)
    end
  end
end

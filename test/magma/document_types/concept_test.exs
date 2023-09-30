defmodule Magma.ConceptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Concept

  alias Magma.{Concept, Matter, Artefact}

  describe "new/1" do
    test "Project matter" do
      title = "Magma"

      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: ^title},
                name: "Project",
                content: nil,
                title: nil,
                prologue: nil,
                sections: nil
              } = concept} =
               title
               |> Matter.Project.new!()
               |> Concept.new()

      assert concept.path == Vault.path("concepts/Project.md")
    end

    test "Module matter" do
      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: TopLevelExample},
                name: "TopLevelExample",
                content: nil,
                title: nil,
                prologue: nil,
                sections: nil
              } = concept} =
               TopLevelExample
               |> Matter.Module.new!()
               |> Concept.new()

      assert concept.path == Vault.path("concepts/modules/TopLevelExample.md")
    end

    test "Text matter" do
      title = "User-Guide"

      assert {:ok,
              %Concept{
                subject: %Matter.Text{type: Matter.Texts.UserGuide, name: ^title},
                name: ^title,
                content: nil,
                title: nil,
                sections: nil
              } = concept} =
               title
               |> Matter.Texts.UserGuide.new()
               |> Concept.new()

      assert concept.path == Vault.path("concepts/texts/#{title}/#{title}.md")
    end
  end

  test "new!/1" do
    assert {:ok, Concept.new!(module_matter())} ==
             Concept.new(module_matter())
  end

  describe "create/2 (and re-load/1)" do
    test "Module matter" do
      expected_path = Vault.path("concepts/modules/Nested/Nested.Example.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: Nested.Example},
                name: "Nested.Example",
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{},
                title: "`Nested.Example`",
                prologue: []
              } = concept} =
               Nested.Example
               |> Matter.Module.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert DateTime.diff(DateTime.utc_now(), concept.created_at, :second) <= 2

      assert Concept.load(concept.path) == {:ok, concept}

      assert Vault.document_path(concept.name) == concept.path
    end

    test "Project matter" do
      expected_path = Vault.path("concepts/Project.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: "Magma"},
                name: "Project",
                tags: ["magma-vault"],
                aliases: ["Magma project", "Magma-project"],
                custom_metadata: %{},
                title: "Magma project",
                prologue: []
              } = concept} =
               "Magma"
               |> Matter.Project.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert DateTime.diff(DateTime.utc_now(), concept.created_at, :second) <= 2

      assert Concept.load(concept.path) == {:ok, concept}

      assert Vault.document_path(concept.name) == concept.path
    end

    test "Text matter" do
      title = "Some User Guide"
      expected_path = Vault.path("concepts/texts/#{title}/#{title}.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Text{
                  type: Magma.Matter.Texts.UserGuide,
                  name: ^title
                },
                name: ^title,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{},
                title: ^title,
                prologue: []
              } = concept} =
               title
               |> Matter.Texts.UserGuide.new()
               |> Concept.create()

      assert concept.path == expected_path
      assert DateTime.diff(DateTime.utc_now(), concept.created_at, :second) <= 2

      assert concept.content ==
               """
               # #{concept.title}

               ## Description

               <!--
               What should "Some User Guide" cover?

               -->


               # Context knowledge

               #{Concept.Template.context_knowledge_hint()}


               # Sections

               <!--
               Don't remove or edit this section! The results of the generated table of contents will be copied to this place.
               -->


               # Artefact previews

               - [[Some User Guide (article) Preview]]


               # Artefacts

               ## TableOfContents

               - Prompt: [[Prompt for Some User Guide ToC]]
               - Final version: [[Some User Guide ToC]]

               ### TableOfContents prompt task

               Your task is to write an outline of "Some User Guide".

               Please provide the outline in the following format:

               ```markdown
               ## Title of the first section

               Abstract: Abstract of the introduction.

               ## Title of the next section

               Abstract: Abstract of the next section.

               ## Title of the another section

               Abstract: Abstract of the another section.
               ```

               <!--
               Please don't change the general structure of this outline format. The section generator relies on an outline with sections.
               -->
               """

      assert Concept.load(concept.path) == {:ok, concept}

      assert Vault.document_path(concept.name) == concept.path
    end

    @tag vault_files: "concepts/texts/Some User Guide/Some User Guide.md"
    test "Section matter" do
      section_matter = user_guide_section_matter()
      text_title = section_matter.main_text.name
      section_title = section_matter.name
      section_name = "#{text_title} - #{section_title}"
      abstract = "An abstract of the introduction"

      expected_path =
        Vault.path("concepts/texts/#{text_title}/#{section_name}.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: ^section_matter,
                name: ^section_name,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{},
                title: ^section_title,
                prologue: []
              } = concept} =
               Concept.create(section_matter, [], assigns: [abstract: abstract])

      assert concept.path == expected_path
      assert DateTime.diff(DateTime.utc_now(), concept.created_at, :second) <= 2

      assert concept.content ==
               """
               # Introduction

               ## Description

               #{abstract}


               # Context knowledge

               #{Concept.Template.context_knowledge_hint()}




               # Artefacts

               ## Article

               - Prompt: [[Prompt for Some User Guide - Introduction (article section)]]
               - Final version: [[Some User Guide - Introduction (article section)]]

               ### Article prompt task

               Your task is to write the section "Introduction" of "Some User Guide".
               """

      assert Concept.load(concept.path) == {:ok, concept}

      assert Vault.document_path(concept.name) == concept.path
    end

    test "when a file at the document path already exists" do
      document_path =
        TestVault.add("concepts/modules/Nested/Nested.Example.md")

      {:ok, existing_document} = Concept.load(document_path)

      send(self(), {:mix_shell_input, :yes?, false})

      assert {:skipped, _} = Concept.create(existing_document)

      assert_receive {:mix_shell, :yes?, [_]}
    end
  end

  describe "load/2" do
    @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
    test "Module matter", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Module{name: Nested.Example},
                 path: ^document_path,
                 name: "Nested.Example",
                 content: content,
                 custom_metadata: %{},
                 aliases: [],
                 tags: ["foo", "bar"],
                 created_at: ~U[2023-07-11 14:25:00Z],
                 title: "`Nested.Example`",
                 prologue: []
               } = concept
             } = Concept.load(document_path)

      assert File.exists?(document_path)

      assert document_path
             |> File.read!()
             |> String.trim()
             |> String.ends_with?(String.trim(content))

      assert Nested.Example
             |> Matter.Module.new!()
             |> Concept.new!()
             |> Concept.load() == {:ok, concept}
    end

    @tag vault_files: "concepts/Project.md"
    test "Project matter", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Project{name: "Some"},
                 path: ^document_path,
                 name: "Project",
                 content: content,
                 custom_metadata: %{},
                 aliases: ["Some project", "Some-project"],
                 tags: ["foo"],
                 created_at: ~U[2023-07-11 14:25:00Z],
                 title: "Some project",
                 prologue: []
               } = concept
             } =
               "Some"
               |> Matter.Project.new!()
               |> Concept.new!()
               |> Concept.load()

      assert document_path
             |> File.read!()
             |> String.trim()
             |> String.ends_with?(String.trim(content))

      assert Concept.load(document_path) == {:ok, concept}
    end

    @tag vault_files: "concepts/texts/Some User Guide/Some User Guide.md"
    test "Text matter", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Text{
                   type: Magma.Matter.Texts.UserGuide,
                   name: "Some User Guide"
                 },
                 path: ^document_path,
                 name: "Some User Guide",
                 content: content,
                 custom_metadata: %{},
                 aliases: [],
                 tags: [],
                 created_at: ~U[2023-09-13 02:41:42.00Z],
                 title: "Some User Guide",
                 prologue: []
               } = concept
             } =
               "Some User Guide"
               |> Matter.Texts.UserGuide.new()
               |> Concept.new!()
               |> Concept.load()

      assert document_path
             |> File.read!()
             |> String.trim()
             |> String.ends_with?(String.trim(content))

      assert Concept.load(document_path) == {:ok, concept}
    end

    @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
    test "with document name", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert Concept.load!("Nested.Example") == Concept.load!(document_path)
    end

    test "when file not exists" do
      assert Concept.load("not_existing.md") ==
               {:error, "not_existing.md not found"}
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "when the file is not a concept document", %{vault_files: [prompt | _]} do
      assert prompt
             |> Vault.path()
             |> Concept.load() ==
               {:error,
                Magma.InvalidDocumentType.exception(
                  document: Vault.path(prompt),
                  expected: Concept,
                  actual: Artefact.Prompt
                )}
    end
  end
end

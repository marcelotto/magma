defmodule Magma.ConceptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Concept

  alias Magma.{Concept, Matter, Artefacts}

  describe "new/1" do
    test "with project matter" do
      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: "Magma"},
                path: path,
                name: "Project",
                custom_metadata: nil,
                content: nil,
                title: nil,
                prologue: nil,
                subject_description: nil,
                subject_notes: nil,
                artefact_specs: nil
              }} = Concept.new(subject: Matter.Project.new("Magma"))

      assert path == Vault.path("__concepts__/Project.md")
    end

    test "with module matter" do
      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: TopLevelExample},
                path: path,
                name: "TopLevelExample",
                custom_metadata: nil,
                content: nil,
                title: nil,
                prologue: nil,
                subject_description: nil,
                subject_notes: nil,
                artefact_specs: nil
              }} = Concept.new(subject: Matter.Module.new(TopLevelExample))

      assert path == Vault.path("__concepts__/modules/TopLevelExample.md")
    end
  end

  test "new/2" do
    assert Nested.Example
           |> Matter.Module.new()
           |> Concept.new([]) ==
             Concept.new(subject: Matter.Module.new(Nested.Example))
  end

  test "new!/1" do
    assert {:ok,
            Nested.Example
            |> Matter.Module.new()
            |> Concept.new!()} ==
             Concept.new(subject: Matter.Module.new(Nested.Example))
  end

  describe "create/2" do
    test "with module matter" do
      expected_path = Vault.path("__concepts__/modules/Nested/Nested.Example.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: Nested.Example},
                name: "Nested.Example",
                tags: ["magma-vault"],
                aliases: [],
                created_at: created_at,
                custom_metadata: %{},
                title: "`Nested.Example`",
                prologue: [],
                subject_description: %Magma.DocumentStruct.Section{title: "Description"},
                subject_notes: %Magma.DocumentStruct.Section{title: "Notes"},
                artefact_specs: [
                  {:commons, %Magma.DocumentStruct.Section{title: "Commons"}},
                  {Artefacts.ModuleDoc, %Magma.DocumentStruct.Section{title: "ModuleDoc"}},
                  {"Cheatsheet", %Magma.DocumentStruct.Section{title: "Cheatsheet"}}
                ]
              } = concept} =
               Nested.Example
               |> Matter.Module.new()
               |> Concept.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert File.exists?(concept.path)
      assert Concept.load(concept.path) == {:ok, concept}

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      assert Vault.document_path(concept.name) == concept.path
    end

    test "with project matter" do
      expected_path = Vault.path("__concepts__/Project.md")

      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: "Magma"},
                name: "Project",
                tags: ["magma-vault"],
                aliases: ["Magma project", "Magma-project"],
                created_at: created_at,
                custom_metadata: %{},
                title: "Magma project",
                prologue: [],
                subject_description: %Magma.DocumentStruct.Section{title: "Description"},
                subject_notes: %Magma.DocumentStruct.Section{title: "Notes"},
                artefact_specs: [
                  {:commons, %Magma.DocumentStruct.Section{title: "Commons"}},
                  {Artefacts.ModuleDoc, %Magma.DocumentStruct.Section{title: "ModuleDoc"}},
                  {"Cheatsheet", %Magma.DocumentStruct.Section{title: "Cheatsheet"}}
                ]
              } = concept} =
               "Magma"
               |> Matter.Project.new()
               |> Concept.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert File.exists?(concept.path)
      assert Concept.load(concept.path) == {:ok, concept}

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      assert Vault.document_path(concept.name) == concept.path
    end

    test "when a file at the document path already exists" do
      document_path =
        TestVault.add("__concepts__/modules/Some/Some.DocumentWithFrontMatter.md")

      {:ok, existing_document} = Concept.load(document_path)

      send(self(), {:mix_shell_input, :yes?, false})

      assert Concept.create(existing_document) == {:ok, existing_document}

      assert_receive {:mix_shell, :yes?, [_]}
    end
  end

  describe "load/2" do
    @tag vault_files: "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
    test "with module matter", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Module{name: Some.DocumentWithFrontMatter},
                 path: ^document_path,
                 name: "Some.DocumentWithFrontMatter",
                 content: content,
                 custom_metadata: %{},
                 aliases: [],
                 tags: ["foo", "bar"],
                 created_at: ~U[2023-07-11 14:25:00Z],
                 title: "`Some.DocumentWithFrontMatter`",
                 prologue: [],
                 subject_description: %Magma.DocumentStruct.Section{title: "Description"},
                 subject_notes: %Magma.DocumentStruct.Section{title: "Notes"},
                 artefact_specs: [
                   commons: %Magma.DocumentStruct.Section{title: "Commons"}
                 ]
               } = concept
             } = Concept.load(document_path)

      assert File.exists?(document_path)

      assert document_path
             |> File.read!()
             |> String.trim()
             |> String.ends_with?(String.trim(content))

      assert Concept.new!(subject: Matter.Module.new(Some.DocumentWithFrontMatter))
             |> Concept.load() == {:ok, concept}
    end

    @tag vault_files: "__concepts__/Project.md"
    test "project matter", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Project{name: "Some Project"},
                 path: ^document_path,
                 name: "Project",
                 content: content,
                 custom_metadata: %{},
                 aliases: ["Some Project project", "Some Project-project"],
                 tags: ["foo"],
                 created_at: ~U[2023-07-11 14:25:00Z],
                 title: "Some Project project",
                 prologue: [],
                 subject_description: %Magma.DocumentStruct.Section{title: "Description"},
                 subject_notes: nil,
                 artefact_specs: nil
               } = concept
             } =
               Concept.new!(subject: Matter.Project.new("Some Project"))
               |> Concept.load()

      assert document_path
             |> File.read!()
             |> String.trim()
             |> String.ends_with?(String.trim(content))

      assert Concept.load(document_path) == {:ok, concept}
    end

    @tag vault_files: "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
    test "with document name", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert Concept.load!("Some.DocumentWithFrontMatter") == Concept.load!(document_path)
    end

    test "when file not exists" do
      assert Concept.load("not_existing.md") ==
               {:error, "not_existing.md not found"}
    end

    @tag vault_files: [
           "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md",
           "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
         ]
    test "when the file is not a concept document", %{vault_files: [prompt | _]} do
      assert prompt
             |> Vault.path()
             |> Concept.load() ==
               {:error, "expected Magma.Concept, but got Magma.Artefact.Prompt"}
    end
  end
end

defmodule Magma.ConceptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Concept

  alias Magma.{Concept, Matter}
  alias Magma.DocumentStruct.Section

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
                sections: nil
              }} = Concept.new(subject: Matter.Project.new("Magma"))

      assert path == Vault.path("concepts/Project.md")
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
                sections: nil
              }} = Concept.new(subject: Matter.Module.new(TopLevelExample))

      assert path == Vault.path("concepts/modules/TopLevelExample.md")
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
               |> Matter.Module.new()
               |> Concept.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert File.exists?(concept.path)
      assert Concept.load(concept.path) == {:ok, concept}

      assert DateTime.diff(DateTime.utc_now(), concept.created_at, :second) <= 2

      assert Vault.document_path(concept.name) == concept.path
    end

    test "with project matter" do
      expected_path = Vault.path("concepts/Project.md")

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
                prologue: []
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
        TestVault.add("concepts/modules/Nested/Nested.Example.md")

      {:ok, existing_document} = Concept.load(document_path)

      send(self(), {:mix_shell_input, :yes?, false})

      assert Concept.create(existing_document) == {:ok, existing_document}

      assert_receive {:mix_shell, :yes?, [_]}
    end
  end

  describe "load/2" do
    @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
    test "with module matter", %{vault_files: vault_file} do
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

      assert Concept.new!(subject: Matter.Module.new(Nested.Example))
             |> Concept.load() == {:ok, concept}
    end

    @tag vault_files: "concepts/Project.md"
    test "project matter", %{vault_files: vault_file} do
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
               Concept.new!(subject: Matter.Project.new("Some"))
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
               {:error, "expected Magma.Concept, but got Magma.Artefact.Prompt"}
    end
  end

  @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
  test "description/1", %{vault_files: vault_file} do
    concept = vault_file |> Vault.path() |> Concept.load!()

    assert %Section{
             title: "Description",
             level: 2,
             content: [
               %Panpipe.AST.Para{children: [%Panpipe.AST.Str{string: "This"} | _]} | _
             ]
           } = Concept.description(concept)
  end

  @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
  test "artefact_system_prompt/1", %{vault_files: vault_file} do
    concept = vault_file |> Vault.path() |> Concept.load!()

    assert %Section{
             title: "Spec",
             level: 3,
             sections: [%Magma.DocumentStruct.Section{title: "Expertise"} | _]
           } = Concept.artefact_system_prompt(concept, ["Commons", "Spec"])
  end
end

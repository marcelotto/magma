defmodule Magma.ConceptTest do
  use Magma.TestCase, async: false

  doctest Magma.Concept

  alias Magma.{Concept, Matter}

  describe "new/1" do
    test "with project matter" do
      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: "Magma"},
                path: path,
                name: "Magma",
                custom_metadata: nil,
                content: nil
              }} = Concept.new(subject: Matter.Project.new("Magma"))

      assert path == Vault.path("__concepts__/Magma.md")
    end

    test "with module matter" do
      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: TopLevelExample},
                path: path,
                name: "TopLevelExample",
                custom_metadata: nil,
                content: nil
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

  describe "create/2" do
    test "with module matter" do
      expected_path = Vault.path("__concepts__/modules/Nested/Nested.Example.md")

      File.rm(expected_path)
      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Module{name: Nested.Example},
                name: "Nested.Example",
                tags: ["magma-vault"],
                aliases: ["Concept of Nested.Example"],
                created_at: created_at,
                custom_metadata: %{}
              } = concept} =
               Nested.Example
               |> Matter.Module.new()
               |> Concept.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert File.exists?(concept.path)
      assert Concept.load(concept.path) == {:ok, concept}

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2
    end

    test "with project matter" do
      expected_path = Vault.path("__concepts__/Magma.md")

      File.rm(expected_path)
      refute File.exists?(expected_path)

      assert {:ok,
              %Concept{
                subject: %Matter.Project{name: "Magma"},
                name: "Magma",
                tags: ["magma-vault"],
                aliases: ["Concept of Magma"],
                created_at: created_at,
                custom_metadata: %{}
              } = concept} =
               "Magma"
               |> Matter.Project.new()
               |> Concept.new!()
               |> Concept.create()

      assert concept.path == expected_path
      assert File.exists?(concept.path)
      assert Concept.load(concept.path) == {:ok, concept}

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2
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
    test "with module matter" do
      document_path =
        TestVault.add("__concepts__/modules/Some/Some.DocumentWithFrontMatter.md")

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
                 created_at: ~U[2023-07-11 14:25:00Z]
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

    test "project matter" do
      document_path = TestVault.add("__concepts__/Some Project.md")

      assert {
               :ok,
               %Magma.Concept{
                 subject: %Matter.Project{name: "Some Project"},
                 path: ^document_path,
                 name: "Some Project",
                 content: content,
                 custom_metadata: %{},
                 aliases: [],
                 tags: ["foo"],
                 created_at: ~U[2023-07-11 14:25:00Z]
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

    test "when file not exists" do
      assert Concept.load("not_existing.md") == {:error, :enoent}
    end
  end
end

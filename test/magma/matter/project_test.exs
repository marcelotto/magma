defmodule Magma.Matter.ProjectTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Matter.Project

  alias Magma.Matter.Project
  alias Magma.{Concept, Matter}

  test "app_name/0" do
    assert Project.app_name() == :magma
  end

  test "modules/0" do
    assert modules = Project.modules()
    assert is_list(modules)
    assert Matter.Module.new!(Magma) in modules
    assert Matter.Module.new!(Vault) in modules
    assert Matter.Module.new!(Project) in modules
  end

  test "Concept creation" do
    expected_path = Vault.path("concepts/Project.md")

    refute File.exists?(expected_path)

    assert {:ok,
            %Concept{
              subject: %Project{name: "Magma"},
              name: "Project",
              tags: ["magma-vault"],
              aliases: ["Magma project", "Magma-project"],
              custom_metadata: %{},
              title: "Magma project",
              prologue: []
            } = concept} =
             "Magma"
             |> Project.new!()
             |> Concept.create()

    assert is_just_now(concept.created_at)

    assert concept.path == expected_path

    assert Concept.load(concept.path) == {:ok, concept}

    assert Vault.document_path(concept.name) == concept.path
  end

  @tag vault_files: "concepts/Project.md"
  test "Concept loading", %{vault_files: vault_file} do
    document_path = Vault.path(vault_file)

    assert {
             :ok,
             %Magma.Concept{
               subject: %Project{name: "Some"},
               path: ^document_path,
               name: "Project",
               custom_metadata: %{},
               aliases: ["Some project", "Some-project"],
               tags: ["foo"],
               created_at: ~N[2023-07-11 14:25:00],
               title: "Some project"
             } = concept
           } =
             "Some"
             |> Project.new!()
             |> Concept.new!()
             |> Concept.load()

    assert document_path
           |> File.read!()
           |> String.trim()
           |> String.ends_with?(String.trim(concept.content))

    assert Concept.load(document_path) == {:ok, concept}
  end
end

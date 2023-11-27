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

    assert concept.content ==
             """
             # Magma project

             ## Description

             <!--
             What is the Magma project about?
             -->


             # Context knowledge

             <!--
             This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

             Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
             -->




             # Artefacts

             ## Readme

             - Prompt: [[Prompt for README]]
             - Final version: [[README]]

             ### Readme prompt task

             Generate a README for project 'Magma' according to its description and the following information:

             -   Hex package name: magma
             -   Repo URL: https://github.com/github_username/repo_name
             -   Documentation URL: https://hexdocs.pm/magma/
             -   Homepage URL:
             -   Demo URL:
             -   Logo path: logo.jpg
             -   Screenshot path:
             -   License: MIT License
             -   Contact: Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - your@email.com
             -   Acknowledgments:

             ("n/a" means not applicable and should result in a removal of the respective parts)
             """

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

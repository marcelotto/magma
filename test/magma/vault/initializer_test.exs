defmodule Magma.Vault.InitializerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault.Initializer

  alias Magma.Vault.Initializer
  alias Magma.{Concept, Matter, Artefact}

  describe "initialize/0" do
    test "copies the base Obsidian vault and creates concepts for the project and modules" do
      refute File.exists?(Vault.path())

      project_name = "Magma-Project"

      assert Initializer.initialize(project_name) == :ok

      assert File.exists?(Vault.path())
      assert File.exists?(Vault.path(".obsidian"))
      assert File.exists?(Vault.path([".obsidian", "plugins"]))
      assert File.exists?(Vault.path([".obsidian", "community-plugins.json"]))

      assert File.exists?(Vault.path(Magma.Prompt.path_prefix()))
      assert File.exists?(Vault.custom_prompt_template_path())

      assert {:ok, %Concept{}} =
               Matter.Module.new!(Magma)
               |> Concept.new!()
               |> Concept.load()

      assert {:ok, %Concept{}} =
               project_name
               |> Matter.Project.new!()
               |> Concept.new!()
               |> Concept.load()
    end

    test "when the vault already exists" do
      File.mkdir(Vault.path())
      assert Initializer.initialize("foo") == {:error, :vault_already_existing}
    end
  end

  describe "create_text/2" do
    @tag vault_files: ["concepts/Project.md"]
    test "creates concept and artefact prompts" do
      text_name = "Example Guide"
      refute Vault.document_path(text_name)

      assert {:ok, %Concept{} = concept} =
               Initializer.create_text(text_name, Matter.Texts.UserGuide)

      assert {:ok, ^concept} = Concept.load(text_name)

      assert {:ok, %Artefact.Prompt{}} =
               Artefact.Prompt.load("Prompt for #{text_name} ToC")
    end
  end
end

defmodule Magma.Vault.InitializerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault.Initializer

  alias Magma.Vault.Initializer
  alias Magma.Concept
  alias Magma.Matter

  describe "initialize/0" do
    test "copies the base Obsidian vault and creates concepts for the project and modules" do
      refute File.exists?(Vault.path())

      project_name = "Magma-Project"

      assert Initializer.initialize(project_name) == :ok

      assert File.exists?(Vault.path())
      assert File.exists?(Vault.path(".obsidian"))
      assert File.exists?(Vault.path([".obsidian", "plugins"]))
      assert File.exists?(Vault.path([".obsidian", "community-plugins.json"]))

      assert {:ok, %Concept{}} =
               Matter.Module.new(Magma)
               |> Concept.new!()
               |> Concept.load()

      assert {:ok, %Concept{}} =
               project_name
               |> Matter.Project.new()
               |> Concept.new!()
               |> Concept.load()
    end

    test "when the vault already exists" do
      File.mkdir(Vault.path())
      assert Initializer.initialize("foo") == {:error, :vault_already_existing}
    end
  end
end

defmodule Magma.Vault.InitializerTest do
  use Magma.TestCase

  doctest Magma.Vault.Initializer

  alias Magma.Vault.Initializer

  describe "initialize/0" do
    test "copies the base Obsidian vault" do
      TestData.clear_vault()

      refute File.exists?(Vault.path())

      assert Initializer.initialize() == :ok

      assert File.exists?(Vault.path())
      assert File.exists?(Vault.path(".obsidian"))
      assert File.exists?(Vault.path([".obsidian", "plugins"]))
      assert File.exists?(Vault.path([".obsidian", "community-plugins.json"]))
    end

    test "when the vault already exists" do
      File.mkdir(Vault.path())
      assert Initializer.initialize() == {:error, :already_existing}
    end
  end
end

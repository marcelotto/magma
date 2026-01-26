defmodule Magma.Vault.InitializerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault.Initializer

  alias Magma.Vault.Initializer

  describe "initialize/0" do
    @tag without_vault: true, reset_after_finished: true
    test "copies the base Obsidian vault and creates vault structure" do
      refute File.exists?(Vault.path())

      assert Initializer.initialize() == :ok

      assert File.exists?(Vault.path())
      assert File.exists?(Vault.path(".gitignore"))
      assert File.exists?(Vault.path(".obsidian"))
      assert File.exists?(Vault.path([".obsidian", "plugins"]))
      assert File.exists?(Vault.path([".obsidian", "community-plugins.json"]))

      assert File.exists?(Magma.Config.path())
      assert File.exists?(Magma.Config.path("Magma.system.config.md"))

      assert File.exists?(Magma.Config.path(".VERSION"))
      assert File.read!(Magma.Config.path(".VERSION")) == to_string(Magma.version())

      assert File.exists?(Vault.path(".bin"))
      assert File.exists?(Vault.path([".bin", "magma.sh"]))
      assert File.exists?(Vault.path([".bin", "magma.bat"]))

      assert File.exists?(Vault.path(Magma.Prompt.path_prefix()))
      assert File.exists?(Vault.custom_prompt_template_path())

      assert File.exists?(Vault.path(Magma.Session.path_prefix()))
      assert File.exists?(Vault.session_template_path())
      assert File.exists?(Vault.session_continuation_template_path())
      assert File.exists?(Vault.session_response_prompt_template_path())
    end

    test "when the vault already exists" do
      File.mkdir(Vault.path())
      assert Initializer.initialize() == {:error, :vault_already_existing}
    end
  end
end

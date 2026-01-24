defmodule Magma.Vault.DiscoveryTest do
  use Magma.TestCase, async: false

  alias Magma.Vault.Discovery

  import ExUnit.CaptureLog

  setup do
    original_dir = Application.get_env(:magma, :dir)
    original_env = System.get_env("MAGMA_VAULT_PATH")
    original_cwd = File.cwd!()

    on_exit(fn ->
      File.cd!(original_cwd)

      if original_dir do
        Application.put_env(:magma, :dir, original_dir)
      else
        Application.delete_env(:magma, :dir)
      end

      if original_env do
        System.put_env("MAGMA_VAULT_PATH", original_env)
      else
        System.delete_env("MAGMA_VAULT_PATH")
      end
    end)

    System.delete_env("MAGMA_VAULT_PATH")

    :ok
  end

  describe "resolve/0" do
    test "environment variable takes highest priority" do
      vault_path = create_temp_vault()
      other_vault = create_temp_vault()

      System.put_env("MAGMA_VAULT_PATH", vault_path)

      config_file = Path.expand(".magma.yaml")
      File.write!(config_file, "vault: #{other_vault}\n")
      on_exit(fn -> File.rm(config_file) end)

      assert Discovery.resolve() == vault_path
    end

    test "current directory with magma.config is second priority" do
      vault_path = create_temp_vault_with_config()
      File.cd!(vault_path)

      # File.cwd!/0 returns the canonical path (resolves symlinks like /var -> /private/var on macOS)
      canonical_path = File.cwd!()

      assert Discovery.resolve() == canonical_path
    end

    test "environment variable takes priority over current directory vault" do
      env_vault = create_temp_vault()
      cwd_vault = create_temp_vault_with_config()

      System.put_env("MAGMA_VAULT_PATH", env_vault)
      File.cd!(cwd_vault)

      assert Discovery.resolve() == env_vault
    end

    test "current directory vault takes priority over .magma.yaml" do
      cwd_vault = create_temp_vault_with_config()
      yaml_vault = create_temp_vault()

      File.cd!(cwd_vault)
      canonical_path = File.cwd!()
      config_file = Path.join(canonical_path, ".magma.yaml")
      File.write!(config_file, "vault: #{yaml_vault}\n")

      assert Discovery.resolve() == canonical_path
    end

    test ".magma.yaml is third priority" do
      vault_path = create_temp_vault()
      non_vault_dir = create_temp_vault()

      File.cd!(non_vault_dir)
      config_file = Path.join(non_vault_dir, ".magma.yaml")
      File.write!(config_file, "vault: #{vault_path}\n")

      assert Discovery.resolve() == vault_path
    end

    test "returns nil when nothing found" do
      assert Discovery.resolve() == nil
    end

    test "validates that environment variable path exists" do
      System.put_env("MAGMA_VAULT_PATH", "/nonexistent/path")

      assert Discovery.resolve() == nil
    end

    test "validates that .magma.yaml path exists" do
      config_file = Path.expand(".magma.yaml")
      File.write!(config_file, "vault: /nonexistent/path\n")
      on_exit(fn -> File.rm(config_file) end)

      assert Discovery.resolve() == nil
    end

    test "ignores empty environment variable" do
      System.put_env("MAGMA_VAULT_PATH", "")

      assert Discovery.resolve() == nil
    end

    test "expands relative paths from environment variable" do
      vault_path = create_temp_vault()
      relative_path = Path.relative_to_cwd(vault_path)

      System.put_env("MAGMA_VAULT_PATH", relative_path)

      assert Discovery.resolve() == vault_path
    end

    test "expands relative paths from .magma.yaml" do
      vault_path = create_temp_vault()
      relative_path = Path.relative_to_cwd(vault_path)

      config_file = Path.expand(".magma.yaml")
      File.write!(config_file, "vault: #{relative_path}\n")
      on_exit(fn -> File.rm(config_file) end)

      assert Discovery.resolve() == vault_path
    end

    test "handles malformed .magma.yaml gracefully" do
      config_file = Path.expand(".magma.yaml")
      File.write!(config_file, "not: valid: yaml: content\n")
      on_exit(fn -> File.rm(config_file) end)

      assert capture_log(fn ->
               assert Discovery.resolve() == nil
             end) =~ "Error reading"
    end

    test "handles .magma.yaml without vault key" do
      config_file = Path.expand(".magma.yaml")
      File.write!(config_file, "other_key: some_value\n")
      on_exit(fn -> File.rm(config_file) end)

      assert Discovery.resolve() == nil
    end
  end

  describe "apply/0" do
    test "updates Application env when path found" do
      vault_path = create_temp_vault()
      System.put_env("MAGMA_VAULT_PATH", vault_path)

      assert :ok = Discovery.apply()
      assert Application.get_env(:magma, :dir) == vault_path
    end

    test "returns ok when nothing found" do
      original = Application.get_env(:magma, :dir)

      assert :ok = Discovery.apply()

      # Application env unchanged
      assert Application.get_env(:magma, :dir) == original
    end

    test "does not modify Application env when nothing found" do
      original_value = "original_test_value"
      Application.put_env(:magma, :dir, original_value)

      Discovery.apply()

      assert Application.get_env(:magma, :dir) == original_value
    end
  end

  defp create_temp_vault do
    path = Path.join(System.tmp_dir!(), "magma_test_vault_#{:rand.uniform(1_000_000)}")
    File.mkdir_p!(path)
    on_exit(fn -> File.rm_rf!(path) end)
    path
  end

  defp create_temp_vault_with_config do
    path = create_temp_vault()
    File.mkdir_p!(Path.join(path, "magma.config"))
    path
  end
end

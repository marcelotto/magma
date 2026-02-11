defmodule Magma.CLI.Command.InitTest do
  use Magma.Vault.Case, async: false, reset_after_finished: true, without_vault: true

  alias Magma.CLI.Command.Init

  defp with_reset_env(fun) do
    original = Application.get_env(:magma, :dir)

    try do
      fun.()
    after
      Application.put_env(:magma, :dir, original)
    end
  end

  describe "run/1 with path argument" do
    @tag :tmp_dir
    test "creates vault at specified path", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "test_vault")

      with_reset_env(fn ->
        File.cd!(tmp_dir, fn ->
          assert :ok = Init.run([path])
          assert File.dir?(path)
          assert File.dir?(Path.join(path, "magma.config"))
        end)
      end)
    end

    @tag :tmp_dir
    test "creates .magma.yaml for non-standard path", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "custom_vault")
      yaml_path = Path.join(tmp_dir, ".magma.yaml")

      with_reset_env(fn ->
        File.cd!(tmp_dir, fn ->
          assert :ok = Init.run([path])
          assert File.exists?(yaml_path)
          assert {:ok, %{"vault" => "custom_vault"}} = YamlElixir.read_from_file(yaml_path)
        end)
      end)
    end

    @tag :tmp_dir
    test "does not create .magma.yaml when path equals current Vault.path()", %{tmp_dir: tmp_dir} do
      default_path = Path.join(tmp_dir, "my_vault")
      yaml_path = Path.join(tmp_dir, ".magma.yaml")

      with_reset_env(fn ->
        Application.put_env(:magma, :dir, default_path)

        File.cd!(tmp_dir, fn ->
          assert :ok = Init.run([default_path])
          refute File.exists?(yaml_path)
        end)
      end)
    end

    test "returns error for too many arguments" do
      assert {:error, "Too many arguments" <> _} = Init.run(["path1", "path2"])
    end
  end

  describe "run/1 with --base-vault option" do
    @tag :tmp_dir
    test "creates vault with named base vault theme", %{tmp_dir: tmp_dir} do
      with_reset_env(fn ->
        Application.put_env(:magma, :dir, Path.join(tmp_dir, "vault"))

        assert :ok = Init.run(["--base-vault", "default"])
        assert File.dir?(Path.join(tmp_dir, "vault/.obsidian"))
      end)
    end

    test "returns error for non-existing theme" do
      assert {:error, "No base vault found at " <> _} =
               Init.run(["--base-vault", "non_existing"])
    end
  end

  describe "run/1 with --base-vault-path option" do
    @tag :tmp_dir
    test "creates vault with custom base vault path", %{tmp_dir: tmp_dir} do
      custom_base = Path.join(tmp_dir, "custom_base")
      obsidian_dir = Path.join(custom_base, ".obsidian")
      File.mkdir_p!(obsidian_dir)
      File.write!(Path.join(obsidian_dir, "test.json"), "{}")

      vault_path = Path.join(tmp_dir, "vault")

      with_reset_env(fn ->
        Application.put_env(:magma, :dir, vault_path)

        assert :ok = Init.run(["--base-vault-path", custom_base])
        assert File.exists?(Path.join(vault_path, ".obsidian/test.json"))
      end)
    end

    test "returns error for non-existing path" do
      assert {:error, "No base vault found at /non/existing/base"} =
               Init.run(["--base-vault-path", "/non/existing/base"])
    end

    @tag :tmp_dir
    test "works combined with path argument", %{tmp_dir: tmp_dir} do
      custom_base = Path.join(tmp_dir, "custom_base")
      obsidian_dir = Path.join(custom_base, ".obsidian")
      File.mkdir_p!(obsidian_dir)
      File.write!(Path.join(obsidian_dir, "custom.json"), "{}")

      vault_path = Path.join(tmp_dir, "my_vault")

      with_reset_env(fn ->
        File.cd!(tmp_dir, fn ->
          assert :ok = Init.run([vault_path, "--base-vault-path", custom_base])
          assert File.exists?(Path.join(vault_path, ".obsidian/custom.json"))
          assert File.dir?(Path.join(vault_path, "magma.config"))
        end)
      end)
    end
  end
end

defmodule Magma.Vault.BaseVaultTest do
  use Magma.TestCase

  doctest Magma.Vault.BaseVault

  alias Magma.Vault.BaseVault

  test "validated_path/0" do
    assert {:ok, path} = BaseVault.validated_path()
    assert String.ends_with?(path, "priv/base_vault/default")
  end

  describe "validated_path/1" do
    test "with existing theme name" do
      assert {:ok, path} = BaseVault.validated_path(:default)
      assert String.ends_with?(path, "priv/base_vault/default")
    end

    test "with non-existing theme name" do
      assert {:error, "No base vault found at " <> _} = BaseVault.validated_path(:invalid)
    end

    test "with existing custom path" do
      path = BaseVault.path(:default)
      assert {:ok, ^path} = BaseVault.validated_path(path)
    end

    test "with non-existing custom path" do
      assert {:error, "No base vault found at /non/existing/path"} =
               BaseVault.validated_path("/non/existing/path")
    end
  end
end

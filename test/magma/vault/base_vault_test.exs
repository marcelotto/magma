defmodule Magma.Vault.BaseVaultTest do
  use Magma.TestCase

  doctest Magma.Vault.BaseVault

  alias Magma.Vault.BaseVault

  test "path!/0" do
    assert path = BaseVault.path!()
    assert File.exists?(path)
    assert String.ends_with?(path, "priv/base_vault/default")
  end

  describe "path!/1" do
    test "with existing theme name" do
      assert path = BaseVault.path!(:default)
      assert File.exists?(path)
      assert String.ends_with?(path, "priv/base_vault/default")
    end

    test "with non-existing theme name" do
      assert_raise RuntimeError, "No base vault found at #{BaseVault.path(:invalid)}", fn ->
        BaseVault.path!(:invalid)
      end
    end
  end
end

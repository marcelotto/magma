defmodule Magma.ConfigTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config

  test "system/0" do
    assert {:ok, Magma.Config.system()} ==
             Magma.Config.System.load()
  end

  test "system/1" do
    assert Magma.Config.system(:default_tags) == ["magma-vault"]
    assert Magma.Config.system(:default_generation) == %Magma.Generation.Mock{}
    assert Magma.Config.system(:link_resolution_style) == :plain
  end

  @tag vault_files: ["concepts/Project.md"]
  test "project/0" do
    assert {:ok, Magma.Config.project()} ==
             Magma.Matter.Project.concept()
  end
end

defmodule Magma.ConfigTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config

  test "system/1" do
    assert Magma.Config.system(:default_tags) == ["magma-vault"]
    assert Magma.Config.system(:default_generation) == %Magma.Generation.Mock{}
    assert Magma.Config.system(:link_resolution_style) == :plain
  end
end

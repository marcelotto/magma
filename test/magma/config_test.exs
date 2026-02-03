defmodule Magma.ConfigTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config

  test "system/0" do
    assert {:ok, Magma.Config.system()} ==
             Magma.Config.System.load()
  end

  test "system/1" do
    assert Magma.Config.system(:default_tags) == []
    assert Magma.Config.system(:default_generation) == %Magma.Generation.Mock{}
    assert Magma.Config.system(:link_resolution_style) == :at_file_ref
    assert Magma.Config.system(:session_response_mode) == :import
    assert Magma.Config.system(:include_prompt_header) == true
  end
end

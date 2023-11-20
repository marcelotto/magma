defmodule Magma.Config.SystemTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config.System

  test "load/1" do
    assert {:ok,
            %Magma.Config.System{
              name: "magma_config",
              tags: ["magma-config"],
              custom_metadata: %{
                default_tags: ["magma-vault"],
                default_generation: %Magma.Generation.Mock{},
                link_resolution_style: :plain
              }
            } = config} = Magma.Config.System.load()

    assert config.path == Vault.path("magma.config/magma_config.md")
  end
end

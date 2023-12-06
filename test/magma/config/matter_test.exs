defmodule Magma.Config.MatterTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config.Matter

  test "load/1" do
    assert {:ok,
            %Magma.Config.Matter{
              name: "Module.matter.config",
              tags: ["magma-config"],
              custom_metadata: %{auto_module_context: true}
            } = config} = Magma.Config.Matter.load("Module.matter.config")

    assert config.content ==
             """
             # Module matter config

             ## Context knowledge
             """

    assert config.path == Vault.path("magma.config/matter/Module.matter.config.md")
  end
end

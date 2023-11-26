defmodule Magma.Config.TextTypeTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config.TextType

  test "load/1" do
    assert {:ok,
            %Magma.Config.TextType{
              name: "Generic.config",
              tags: ["magma-config"],
              custom_metadata: %{
                text_type_label: "Text"
              }
            } = config} = Magma.Config.TextType.load("Generic.config")

    assert config.content ==
             """
             # Generic text type config

             ## System prompt

             Your task is to help write a text. It should be written in English in the Markdown format.


             ## Context knowledge
             """

    assert config.path == Vault.path("magma.config/text_types/Generic.config.md")
  end

  test "create/1" do
    assert {:ok,
            %Magma.Config.TextType{
              name: "Foo.config",
              text_type: Magma.Matter.Texts.Foo,
              tags: ["magma-config"],
              custom_metadata: %{
                text_type_label: "foo"
              }
            } = config} = Magma.Config.TextType.create("Foo", label: "foo")

    assert config.path == Vault.path("magma.config/text_types/#{config.name}.md")

    assert config.content ==
             """
             # Foo text type config

             ## System prompt


             ## Context knowledge

             """

    assert Magma.Config.TextType.load!(config.path) |> Map.put(:sections, nil) == config
  end
end

defmodule Magma.PromptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Prompt

  alias Magma.{Generation, Prompt}

  test "create/1 and re-load/1 of custom prompt" do
    assert {:ok,
            %Prompt{
              generation: %Generation.Mock{},
              tags: [],
              aliases: [],
              custom_metadata: %{}
            } = prompt} = Prompt.create("Foo")

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Foo"
    assert prompt.path == Vault.path("prompts/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             ![[Magma.system.config#Persona|]]

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of.

             ![[Magma.system.config#Context knowledge|]]


             ## Request

             """

    assert Prompt.load(prompt.path) == {:ok, prompt}
  end
end

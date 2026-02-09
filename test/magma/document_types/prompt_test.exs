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

             ## Context

             ### Knowledge Base

             Read the following documents carefully:

             -

             ## Task

             """

    assert Prompt.load(prompt.path) == {:ok, prompt}
  end
end

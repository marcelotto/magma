defmodule Magma.PromptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Prompt

  alias Magma.{Generation, Prompt}

  @tag vault_files: ["concepts/Project.md"]
  test "create/1 and re-load/1 of custom prompt" do
    assert {:ok,
            %Prompt{
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} = Prompt.create("Foo")

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Foo"
    assert prompt.path == Vault.path("custom_prompts/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             You are MagmaGPT, an assistant who helps the developers of the "Some" project during documentation and development. Your responses are in plain and clear English, so even non-native speakers can easily understand you.

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #### Description of the Some project ![[Project#Description|]]


             ## Request

             """

    assert Prompt.load(prompt.path) == {:ok, prompt}
  end
end

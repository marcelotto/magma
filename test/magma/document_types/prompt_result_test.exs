defmodule Magma.PromptResultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.PromptResult

  alias Magma.{Prompt, PromptResult, Generation}

  import Magma.View

  describe "new/1" do
    test "custom prompt" do
      prompt = prompt()
      created_at = naive_datetime()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: nil,
                tags: nil,
                aliases: nil,
                created_at: ^created_at,
                content: nil
              } = result} =
               PromptResult.new(prompt, created_at: created_at)

      assert result.name ==
               "#{prompt.name} (Prompt result #{NaiveDateTime.to_iso8601(naive_datetime()) |> String.replace(":", "")})"

      assert result.path ==
               Vault.path("prompts/__prompt_results__/#{result.name}.md")
    end
  end

  describe "create/1 (and re-load/1)" do
    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "custom prompt (with prompt-specified generation)" do
      prompt = Prompt.load!("Foo-Prompt")

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Foo-Prompt (" <> _,
                tags: [],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} = PromptResult.create(prompt)

      assert is_just_now(prompt_result.created_at)

      assert prompt_result.content ==
               """

               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'

               foo
               """

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "custom prompt (with explicit generation)" do
      prompt = Prompt.load!("Foo-Prompt")

      generation =
        Generation.Mock.new!(
          expected_system_prompt:
            "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
          expected_prompt: "Elixir is ...\n",
          result: "bar"
        )

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Foo-Prompt (" <> _,
                tags: [],
                aliases: [],
                custom_metadata: %{}
              }} = PromptResult.create(prompt, generation: generation)
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "custom prompt without execution (non-interactive; prompt-specified generation)" do
      prompt = Prompt.load!("Foo-Prompt")

      prompt_with_manual_generation = struct(prompt, generation: Generation.Manual.new!())

      assert {:ok,
              %PromptResult{
                prompt: ^prompt_with_manual_generation,
                generation: %Generation.Manual{},
                name: "Foo-Prompt (" <> _,
                tags: [],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt_with_manual_generation, [], interactive: false)

      assert is_just_now(prompt_result.created_at)

      assert prompt_result.content ==
               """

               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'


               """
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "custom prompt without execution (interactive; explicit generation)" do
      prompt = Prompt.load!("Foo-Prompt")
      answer = "awesome"

      generation = Generation.Manual.new!()

      send(self(), {:shell_input, :prompt, answer})

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Foo-Prompt (" <> _,
                tags: [],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt, generation: generation)

      assert prompt_result.content ==
               """

               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'

               #{answer}
               """

      assert_receive {:shell, :prompt, [_]}

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end
  end
end

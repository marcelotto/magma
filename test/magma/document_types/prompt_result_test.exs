defmodule Magma.PromptResultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.PromptResult

  alias Magma.{Prompt, PromptResult, Artefact, Generation}

  import Magma.View

  # integration tests for prompt results documents from artefact prompts
  # of concrete artefacts can be found as part of the respective artefact tests

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
               "#{prompt.name} (Prompt result #{NaiveDateTime.to_iso8601(naive_datetime())})"

      assert result.path ==
               Vault.path("custom_prompts/__prompt_results__/#{result.name}.md")
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
                tags: ["magma-vault"],
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
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = PromptResult.create(prompt, generation: generation)
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "artefact prompt without execution (interactive; prompt-specified generation)" do
      prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

      prompt_with_manual_generation = struct(prompt, generation: Generation.Manual.new!())
      answer = "awesome"

      send(self(), {:mix_shell_input, :prompt, answer})

      assert {:ok,
              %PromptResult{
                prompt: ^prompt_with_manual_generation,
                generation: %Generation.Manual{},
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt_with_manual_generation)

      assert_receive {:mix_shell, :prompt, [_]}

      assert is_just_now(prompt_result.created_at)

      assert prompt_result.content ==
               """

               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[ModuleDoc of Nested.Example]]

               >[!attention]
               >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

               # Generated ModuleDoc of Nested.Example

               #{answer}
               """
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "artefact prompt without execution (non-interactive; explicit generation)" do
      prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

      generation = Generation.Manual.new!()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt, [generation: generation], interactive: false)

      assert prompt_result.content ==
               """

               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[ModuleDoc of Nested.Example]]

               >[!attention]
               >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

               # Generated ModuleDoc of Nested.Example


               """

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
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
                tags: ["magma-vault"],
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

      send(self(), {:mix_shell_input, :prompt, answer})

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Foo-Prompt (" <> _,
                tags: ["magma-vault"],
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

      assert_receive {:mix_shell, :prompt, [_]}

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md",
           "artefacts/generated/texts/Some User Guide/article/Prompt for Some User Guide - Introduction (article section).md",
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "initial header handling" do
      prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
          result: """
          ## Initial header

          42
          """
        )

      assert {:ok, %PromptResult{} = prompt_result} =
               PromptResult.create(prompt, generation: generation)

      assert prompt_result.content ==
               """

               #{PromptResult.controls(prompt_result)}

               # Generated ModuleDoc of Nested.Example

               ## Initial header

               42
               """

      prompt =
        Artefact.Prompt.load!("Prompt for Some User Guide - Introduction (article section)")

      generation =
        Generation.Mock.new!(
          expected_system_prompt:
            "You are MagmaGPT, a software developer on the \"Some\" project with a lot of experience with Elixir and writing high-quality documentation.\n",
          expected_prompt: "Generate the \"Introduction\" section of Some User Guide ...\n",
          result: """
          ## Introduction

          42
          """
        )

      assert {:ok, %PromptResult{} = prompt_result} =
               PromptResult.create(prompt, generation: generation)

      assert prompt_result.content ==
               """

               #{PromptResult.controls(prompt_result)}

               # Generated Some User Guide - Introduction (article section)

               42
               """
    end
  end
end

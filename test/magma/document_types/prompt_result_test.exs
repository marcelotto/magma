defmodule Magma.PromptResultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.PromptResult

  alias Magma.{Prompt, PromptResult, Artefact, Generation}

  import Magma.Obsidian.View.Helper

  describe "new/1" do
    test "ModuleDoc artefact prompt" do
      prompt = module_doc_artefact_prompt()
      created_at = datetime()

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
               "Generated ModuleDoc of Nested.Example (#{datetime() |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"

      assert result.path ==
               Vault.path(
                 "artefacts/generated/modules/Nested/Example/__prompt_results__/#{result.name}.md"
               )
    end

    test "custom prompt" do
      prompt = prompt()
      created_at = datetime()

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
               "#{prompt.name} (Prompt result #{datetime() |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"

      assert result.path ==
               Vault.path("custom_prompts/__prompt_results__/#{result.name}.md")
    end

    #    test "without created_at" do
    #      prompt = module_doc_artefact_prompt()
    #
    #      assert PromptResult.new(prompt) == {:error, "missing attribute: :created_at"}
    #    end
  end

  describe "create/1 (and re-load/1)" do
    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "ModuleDoc artefact prompt", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} = PromptResult.create(prompt)

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[ModuleDoc of Nested.Example]]

               # Generated ModuleDoc of Nested.Example

               foo
               """

      assert File.stat!(prompt_result.path).access == :read

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
          result: "bar"
        )

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = PromptResult.create(prompt, generation: generation)
    end

    @tag vault_files: [
           "artefacts/generated/texts/Some User Guide/Prompt for Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "TableOfContents artefact prompt", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Generated Some User Guide ToC (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} = PromptResult.create(prompt)

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[Some User Guide ToC]]

               # Generated Some User Guide ToC

               foo
               """

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}

      generation =
        Generation.Mock.new!(
          expected_system_prompt: Prompt.Template.persona(project_concept()) <> "\n",
          expected_prompt: "Generate the table of content of Some User Guide ...\n",
          result: "bar"
        )

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated Some User Guide ToC (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = PromptResult.create(prompt, generation: generation)
    end

    @tag vault_files: [
           "artefacts/generated/texts/Some User Guide/article/Prompt for Some User Guide - Introduction (article section).md",
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "Section artefact prompt", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Generated Some User Guide - Introduction (article section) (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} = PromptResult.create(prompt)

      assert prompt_result.content ==
               """
               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[Some User Guide - Introduction (article section)]]

               # Generated Some User Guide - Introduction (article section)

               foo
               """

      assert prompt_result.path ==
               Vault.path(
                 "artefacts/generated/texts/Some User Guide/article/__prompt_results__/#{prompt_result.name}.md"
               )

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "with custom prompt" do
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

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'

               foo
               """

      assert File.stat!(prompt_result.path).access == :read

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}

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
    test "artefact prompt without execution", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

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

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{delete_current_file_button()}

               Final version: [[ModuleDoc of Nested.Example]]

               # Generated ModuleDoc of Nested.Example

               #{answer}
               """

      assert File.stat!(prompt_result.path).access == :read_write

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

               # Generated ModuleDoc of Nested.Example


               """

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "custom prompt without execution" do
      prompt = Prompt.load!("Foo-Prompt")

      prompt_with_manual_generation = struct(prompt, generation: Generation.Manual.new!())
      answer = "awesome"

      send(self(), {:mix_shell_input, :prompt, answer})

      assert {:ok,
              %PromptResult{
                prompt: ^prompt_with_manual_generation,
                generation: %Generation.Manual{},
                name: "Foo-Prompt (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt_with_manual_generation)

      assert_receive {:mix_shell, :prompt, [_]}

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'

               #{answer}
               """

      assert File.stat!(prompt_result.path).access == :read_write

      generation = Generation.Manual.new!()

      assert {:ok,
              %PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Foo-Prompt (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} =
               PromptResult.create(prompt, [generation: generation], interactive: false)

      assert prompt_result.content ==
               """
               #{delete_current_file_button()}

               # Prompt result of '#{prompt.name}'


               """

      assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "initial header is trimmed (unless trim_header: false)", %{
      vault_files: [prompt_file | _]
    } do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
          result: """
          # Initial header

          42
          """
        )

      assert {:ok, %PromptResult{} = prompt_result} =
               PromptResult.create(prompt, generation: generation)

      assert prompt_result.content ==
               """
               #{PromptResult.controls(prompt_result)}

               # Generated ModuleDoc of Nested.Example

               42
               """

      assert {:ok, %PromptResult{} = prompt_result} =
               PromptResult.create(prompt, [generation: generation], trim_header: false)

      assert prompt_result.content ==
               """
               #{PromptResult.controls(prompt_result)}

               # Generated ModuleDoc of Nested.Example

               # Initial header

               42
               """
    end
  end
end

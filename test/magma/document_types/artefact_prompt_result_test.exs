defmodule Magma.Artefact.PromptResultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.PromptResult

  alias Magma.{Artefact, Generation}

  describe "new/1" do
    test "with ModuleDoc prompt" do
      prompt = module_doc_artefact_prompt()
      created_at = datetime()

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: nil,
                path: path,
                name: name,
                tags: nil,
                aliases: nil,
                created_at: ^created_at,
                custom_metadata: nil,
                content: nil
              }} =
               Artefact.PromptResult.new(prompt, created_at: created_at)

      assert name ==
               "Generated ModuleDoc of Nested.Example (#{datetime() |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"

      assert path ==
               Vault.path(
                 "__artefacts__/modules/Nested.Example/moduledoc/prompt_results/#{name}.md"
               )
    end
  end

  describe "create/1" do
    @tag vault_files: [
           "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md",
           "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
         ]
    test "moduledoc", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      prompt_result = Artefact.PromptResult.new!(prompt)

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Generated ModuleDoc of Some.DocumentWithFrontMatter (" <> _,
                content: content,
                tags: ["magma-vault"],
                aliases: [],
                created_at: created_at,
                custom_metadata: %{}
              }} = Artefact.PromptResult.create(prompt_result)

      assert content ==
               """
               #{Magma.Obsidian.View.Helper.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}

               # Generated ModuleDoc of Some.DocumentWithFrontMatter

               foo

               """

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Some.DocumentWithFrontMatter`.\n",
          result: "bar"
        )

      prompt_result = Artefact.PromptResult.new!(prompt, generation: generation)

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated ModuleDoc of Some.DocumentWithFrontMatter (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = Artefact.PromptResult.create(prompt_result)
    end
  end
end

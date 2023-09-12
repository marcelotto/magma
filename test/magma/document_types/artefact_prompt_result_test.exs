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
                 "artefacts/generated/modules/Nested/Example/__prompt_results__/#{name}.md"
               )
    end
  end

  describe "create/1" do
    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
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
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                content: content,
                tags: ["magma-vault"],
                aliases: [],
                created_at: created_at,
                custom_metadata: %{}
              }} = Artefact.PromptResult.create(prompt_result)

      assert content ==
               """
               #{Magma.Obsidian.View.Helper.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{Magma.Obsidian.View.Helper.delete_current_file_button()}

               # Generated ModuleDoc of Nested.Example

               foo

               """

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
          result: "bar"
        )

      prompt_result = Artefact.PromptResult.new!(prompt, generation: generation)

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = Artefact.PromptResult.create(prompt_result)
    end
  end
end

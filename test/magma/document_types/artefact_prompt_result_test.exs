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

  describe "create/1 (and re-load/1)" do
    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "moduledoc", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: %Generation.Mock{},
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt_result} = Artefact.PromptResult.create(prompt)

      assert DateTime.diff(DateTime.utc_now(), prompt_result.created_at, :second) <= 2

      assert prompt_result.content ==
               """
               #{Magma.Obsidian.View.Helper.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
               #{Magma.Obsidian.View.Helper.delete_current_file_button()}

               # Generated ModuleDoc of Nested.Example

               foo
               """

      assert File.stat!(prompt_result.path).access == :read

      assert Artefact.PromptResult.load(prompt_result.path) == {:ok, prompt_result}

      generation =
        Generation.Mock.new!(
          expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
          expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
          result: "bar"
        )

      assert {:ok,
              %Artefact.PromptResult{
                prompt: ^prompt,
                generation: ^generation,
                name: "Generated ModuleDoc of Nested.Example (" <> _,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              }} = Artefact.PromptResult.create(prompt, generation: generation)
    end
  end
end

defmodule Magma.DocumentTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Document

  alias Magma.{Document, Concept, Artefact}

  describe "recreate/1" do
    @tag vault_files: "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
    test "with concept", %{vault_files: concept_file} do
      original_concept =
        concept_file
        |> Vault.path()
        |> Concept.load!()
        |> struct(created_at: datetime())

      assert {:ok, %Concept{created_at: created_at} = new_concept} =
               Document.recreate(original_concept)

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      assert struct(new_concept,
               created_at: nil,
               content: nil,
               sections: nil
             ) ==
               struct(original_concept,
                 created_at: nil,
                 content: nil,
                 sections: nil
               )
    end

    @tag vault_files: [
           "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md",
           "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md",
           "__concepts__/Project.md"
         ]
    test "with prompt", %{vault_files: [prompt_file | _]} do
      original_prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> struct(created_at: datetime())

      assert {:ok, %Artefact.Prompt{created_at: created_at} = new_prompt} =
               Document.recreate(original_prompt)

      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2

      assert struct(new_prompt,
               created_at: nil,
               content: nil
             ) ==
               struct(original_prompt,
                 created_at: nil,
                 content: nil
               )
    end
  end
end

defmodule Magma.DocumentTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Document

  alias Magma.{Document, Concept, Artefact}

  describe "recreate/1" do
    @tag vault_files: [
           "concepts/modules/Nested/Nested.Example.md",
           "concepts/Project.md"
         ]
    test "with concept", %{vault_files: [concept_file | _]} do
      original_concept =
        concept_file
        |> Vault.path()
        |> Concept.load!()
        |> struct(created_at: datetime())

      assert {:ok, %Concept{} = new_concept} =
               Document.recreate(original_concept)

      assert is_just_now(new_concept.created_at)

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
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md",
           "concepts/Project.md"
         ]
    test "with prompt", %{vault_files: [prompt_file | _]} do
      original_prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> struct(created_at: datetime())

      assert {:ok, %Artefact.Prompt{} = new_prompt} =
               Document.recreate(original_prompt)

      assert is_just_now(new_prompt.created_at)

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

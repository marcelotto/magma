defmodule Magma.ConceptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Concept

  alias Magma.{Concept, Artefact}

  # integration tests of concept documents with concrete matter
  # can be found as part of the respective matter and text type tests

  describe "create/3" do
    test "when a file at the document path already exists" do
      document_path =
        TestVault.add("concepts/modules/Nested/Nested.Example.md")

      {:ok, existing_document} = Concept.load(document_path)

      send(self(), {:mix_shell_input, :yes?, false})

      assert {:skipped, _} = Concept.create(existing_document)

      assert_receive {:mix_shell, :yes?, [_]}
    end
  end

  describe "load/2" do
    @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
    test "with document name", %{vault_files: vault_file} do
      document_path = Vault.path(vault_file)

      assert Concept.load!("Nested.Example") == Concept.load!(document_path)
    end

    test "when file not exists" do
      assert Concept.load("not_existing.md") ==
               {:error, "not_existing.md not found"}
    end

    @tag vault_files: [
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md"
         ]
    test "when the file is not a concept document", %{vault_files: [prompt | _]} do
      assert prompt
             |> Vault.path()
             |> Concept.load() ==
               {:error,
                Magma.InvalidDocumentType.exception(
                  document: Vault.path(prompt),
                  expected: Concept,
                  actual: Artefact.Prompt
                )}
    end
  end
end

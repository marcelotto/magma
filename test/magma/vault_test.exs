defmodule Magma.VaultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault

  alias Magma.{Vault, Document}

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/Project.md",
         "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
         "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
         "artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md"
       ]
  test "document_type/1", %{
    vault_files: [module_concept, project_concept, prompt, prompt_result, version]
  } do
    assert module_concept |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Concept}

    assert project_concept |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Concept}

    assert prompt |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Artefact.Prompt}

    assert prompt_result |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Artefact.PromptResult}

    assert version |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Artefact.Version}

    assert module_concept |> Vault.path() |> Vault.document_type() ==
             module_concept |> Document.name_from_path() |> Vault.document_type()

    assert prompt |> Vault.path() |> Vault.document_type() ==
             prompt |> Document.name_from_path() |> Vault.document_type()
  end
end

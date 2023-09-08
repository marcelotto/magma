defmodule Magma.VaultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault

  alias Magma.{Vault, Document}

  @tag vault_files: [
         "concepts/modules/Some/Some.DocumentWithFrontMatter.md",
         "concepts/Project.md",
         "artefacts/generated/modules/Some/DocumentWithFrontMatter/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md"
       ]
  test "document_type/1", %{vault_files: [module_concept, project_concept, moduledoc_prompt]} do
    assert module_concept |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Concept, Magma.Matter.Module}

    assert project_concept |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Concept, Magma.Matter.Project}

    assert moduledoc_prompt |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Artefact.Prompt, Magma.Artefacts.ModuleDoc}

    assert module_concept |> Vault.path() |> Vault.document_type() ==
             module_concept |> Document.name_from_path() |> Vault.document_type()

    assert moduledoc_prompt |> Vault.path() |> Vault.document_type() ==
             moduledoc_prompt |> Document.name_from_path() |> Vault.document_type()
  end
end

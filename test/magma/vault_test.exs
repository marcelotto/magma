defmodule Magma.VaultTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Vault

  alias Magma.{Vault, Document}

  @tag vault_files: [
         "prompts/Foo-Prompt.md",
         "prompts/__prompt_results__/Foo-Prompt - PromptResult (2023-08-15T151602).md"
       ]
  test "document_type/1", %{vault_files: [prompt, prompt_result]} do
    assert prompt |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.Prompt}

    assert prompt_result |> Document.name_from_path() |> Vault.document_type() ==
             {:ok, Magma.PromptResult}

    assert prompt |> Vault.path() |> Vault.document_type() ==
             prompt |> Document.name_from_path() |> Vault.document_type()
  end
end

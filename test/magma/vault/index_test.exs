defmodule Magma.Vault.IndexTest do
  use Magma.Vault.Case, async: false

  alias Magma.Vault.Index

  describe "get_document_path/1" do
    @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
    test "with name of existing document", %{vault_files: document_path} do
      assert Index.get_document_path("Nested.Example") ==
               TestVault.path(document_path)
    end

    test "with name of non-existing document" do
      assert Index.get_document_path("non-existing") == nil
    end
  end
end

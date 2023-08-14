defmodule Magma.Vault.CodeSyncTest do
  use Magma.TestCase, async: false

  doctest Magma.Vault.CodeSync

  alias Magma.Vault.CodeSync
  alias Magma.Concept
  alias Magma.Matter

  describe "sync/0" do
    test "creates concepts for the modules when they don't exist yet" do
      TestVault.clear()
      Vault.create("Magma-Project", :default, code_sync: false)

      assert CodeSync.sync() == :ok

      [
        Magma,
        Magma.Vault,
        Magma.Concept,
        Magma.Vault.CodeSync
      ]
      |> Enum.each(fn module ->
        assert {:ok, %Concept{}} =
                 Matter.Module.new(module)
                 |> Concept.new!()
                 |> Concept.load()
      end)
    end

    test "when the vault not exists" do
      TestVault.clear()
      assert CodeSync.sync() == {:error, :vault_not_existing}
    end
  end
end

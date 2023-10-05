defmodule Magma.Matter.ModuleTest do
  use Magma.Vault.Case

  doctest Magma.Matter.Module

  alias Magma.Matter

  describe "code/1" do
    test "returns the code of the given module" do
      assert Matter.Module.code(TopLevelExample) ==
               File.read!("test/modules/top_level_example.ex")

      assert Matter.Module.code(Nested.Example) ==
               File.read!("test/modules/nested/example.ex")
    end

    test "not a module" do
      assert Matter.Module.code(:foo) == nil
    end

    test "code not present" do
      assert Matter.Module.code(Mix) == nil
    end
  end

  test "context_modules/2" do
    assert Matter.Module.context_modules(Magma) == []
    assert Matter.Module.context_modules(Magma.Document) == [Magma]

    assert Matter.Module.context_modules(Magma.DocumentStruct.Section) == [
             Magma,
             Magma.DocumentStruct
           ]

    assert Matter.Module.context_modules(Magma.Obsidian.View.Helper) == [
             Magma,
             Magma.Obsidian,
             Magma.Obsidian.View
           ]
  end

  @tag vault_files: ["concepts/modules/Nested/Nested.Example.md"]
  test "submodules/1" do
    assert Matter.Module.submodules(Nested) ==
             [Nested.Example]
  end
end

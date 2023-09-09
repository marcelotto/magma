defmodule Magma.Matter.ModuleTest do
  use Magma.TestCase

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
  end
end

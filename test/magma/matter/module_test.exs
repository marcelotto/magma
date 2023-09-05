defmodule Magma.Matter.ModuleTest do
  use Magma.TestCase

  doctest Magma.Matter.Module

  alias Magma.Matter

  describe "code/1" do
    test "returns the code of the given module" do
      assert Matter.Module.code(TopLevelExample) ==
               """
               defmodule TopLevelExample do
                 #  use Magma, "Short description"

                 def foo, do: :bar
               end
               """

      assert Matter.Module.code(Nested.Example) ==
               """
               defmodule Nested.Example do
                 #  use Magma, "Short description"

                 def foo, do: :bar
               end
               """
    end

    test "not a module" do
      assert Matter.Module.code(:foo) == nil
    end
  end
end

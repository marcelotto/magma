defmodule MagmaTest do
  use ExUnit.Case
  doctest Magma

  test "greets the world" do
    assert Magma.hello() == :world
  end
end

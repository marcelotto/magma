defmodule Magma.Matter.ProjectTest do
  use Magma.TestCase

  doctest Magma.Matter.Project

  alias Magma.Matter
  alias Magma.Matter.Project

  test "app_name/0" do
    assert Project.app_name() == :magma
  end

  test "modules/0" do
    assert modules = Project.modules()
    assert is_list(modules)
    assert Matter.Module.new!(Magma) in modules
    assert Matter.Module.new!(Vault) in modules
    assert Matter.Module.new!(Project) in modules
  end
end

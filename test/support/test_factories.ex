defmodule Magma.TestFactories do
  @moduledoc """
  Test factories.
  """

  alias Magma.{
    Concept,
    Matter
  }

  def project_matter do
    Matter.Project.new("Magma")
  end

  def module_matter(mod \\ Nested.Example) do
    Matter.Module.new(mod)
  end

  def project_concept do
    project_matter()
    |> Concept.new()
  end

  def module_concept(mod \\ Nested.Example) do
    mod
    |> module_matter()
    |> Concept.new()
  end
end

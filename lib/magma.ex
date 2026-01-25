defmodule Magma do
  @moduledoc """
  Magma is an environment for writing and executing complex prompts.

  It is primarily designed to support developers in documenting their projects.
  It provides a system of documents for predefined workflows, to generate
  various documentation artefacts.

  Read the [User Guide](Magma User Guide - Introduction to Magma (article section).md) to learn more.
  """

  def version do
    Application.spec(:magma)[:vsn] |> List.to_string() |> Version.parse!()
  end
end

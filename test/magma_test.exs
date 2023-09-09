defmodule MagmaTest do
  use ExUnit.Case

  doctest Magma

  # The __using__/1 and defmoduledoc/0 macros are difficult to test directly,
  # since they are running at compile-time and rely on respective
  # generated moduledoc artefact version documents beforehand, which is hard
  # to achieve.
  # However, since we're using Magma to document itself, a proper generation
  # of the documentation with ExDoc should be sufficient as a test.
end

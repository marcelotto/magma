defmodule Magma.TestCase do
  @moduledoc """
  Common `ExUnit.CaseTemplate` for Magma tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Magma.TestData
      alias Magma.ExampleVault
      alias Magma.Vault

      import unquote(__MODULE__)
    end
  end
end

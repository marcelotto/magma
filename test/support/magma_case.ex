defmodule Magma.TestCase do
  @moduledoc """
  Common `ExUnit.CaseTemplate` for Magma tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Magma.TestVault
      alias Magma.Vault

      import Magma.TestFactories

      import unquote(__MODULE__)
    end
  end
end

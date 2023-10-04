defmodule Magma.TestCase do
  @moduledoc """
  Common `ExUnit.CaseTemplate` for Magma tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Magma.TestData
      alias Magma.TestVault
      alias Magma.Vault

      import Magma.TestFactories

      import unquote(__MODULE__)
    end
  end

  def is_just_now(%DateTime{} = datetime) do
    DateTime.diff(DateTime.utc_now(), datetime, :second) <= 2
  end

  def is_just_now(%NaiveDateTime{} = datetime) do
    NaiveDateTime.diff(NaiveDateTime.local_now(), datetime, :second) <= 2
  end
end

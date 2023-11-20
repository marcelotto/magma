defmodule Magma.Vault.Case do
  @moduledoc """
  Common `ExUnit.CaseTemplate` for Magma tests over the files of the vault.
  """

  use ExUnit.CaseTemplate

  alias Magma.TestVault
  alias Magma.Vault

  using do
    quote do
      use Magma.TestCase

      import unquote(__MODULE__)

      setup context do
        TestVault.clear()

        unless context[:without_vault] do
          File.mkdir!(Vault.path())
          Vault.Initializer.create_config()
          Magma.Vault.Case.setup_files(context[:vault_files])
        end

        on_exit(fn -> TestVault.clear() end)
      end
    end
  end

  def setup_files(nil), do: nil

  def setup_files(files) when is_list(files) do
    Enum.each(files, &setup_files(&1))
  end

  def setup_files(file) do
    TestVault.add_indexed(file)
  end

  def abs_path(abs_path) do
    Path.expand(abs_path, File.cwd!())
  end
end

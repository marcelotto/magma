defmodule Magma.Vault.Initializer do
  alias Magma.Vault
  alias Magma.Vault.{BaseVault, CodeSync}
  alias Magma.Matter.Project
  alias Magma.Concept

  import Magma.MixHelper

  def initialize(project_name, base_vault \\ nil, opts \\ []) do
    with :ok <- base_vault |> BaseVault.path!() |> create_vault() do
      create_project(project_name)

      if Keyword.get(opts, :code_sync, true) do
        CodeSync.sync(opts)
      else
        :ok
      end
    end
  end

  defp create_vault(base_vault) do
    vault_dest_dir = Vault.path()

    if File.exists?(vault_dest_dir) do
      {:error, :vault_already_existing}
    else
      Mix.Generator.create_directory(vault_dest_dir)

      base_vault
      |> Path.join(".obsidian")
      |> copy_directory(vault_dest_dir)

      :ok
    end
  end

  defp create_project(project_name) do
    project_name
    |> Project.new!()
    |> Concept.create()
  end
end

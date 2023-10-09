defmodule Magma.Vault.Initializer do
  alias Magma.Vault
  alias Magma.Vault.{BaseVault, CodeSync}
  alias Magma.Matter.Project
  alias Magma.{Concept, Prompt, Document, Generation}

  import Magma.MixHelper

  def initialize(project_name, base_vault \\ nil, opts \\ []) do
    with :ok <- base_vault |> BaseVault.path!() |> create_vault(opts) do
      {:ok, project} = create_project(project_name)

      create_custom_prompt_template(project)

      if Keyword.get(opts, :code_sync, true) do
        CodeSync.sync(opts)
      else
        :ok
      end
    end
  end

  defp create_vault(base_vault, opts) do
    vault_dest_dir = Vault.path()

    if File.exists?(vault_dest_dir) && !Keyword.get(opts, :force) do
      {:error, :vault_already_existing}
    else
      Mix.Generator.create_directory(vault_dest_dir)

      Prompt.path_prefix()
      |> Vault.path()
      |> Mix.Generator.create_directory()

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

  def create_custom_prompt_template(project) do
    prompt =
      "default"
      |> Prompt.new!(generation: Generation.default().new!())
      |> Document.init()

    Vault.custom_prompt_template_path()
    |> create_file(Prompt.Template.custom_prompt_obsidian_template(project, prompt))
  end
end

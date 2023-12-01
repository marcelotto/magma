defmodule Magma.Vault.Initializer do
  @moduledoc false

  alias Magma.Vault
  alias Magma.Vault.{BaseVault, CodeSync}
  alias Magma.Matter.Project
  alias Magma.{Concept, Prompt, Document, Generation}

  import Magma.MixHelper

  @bin_dir :code.priv_dir(:magma) |> Path.join(".bin")

  @spec initialize(binary, base_vault :: BaseVault.theme() | Path.t() | nil, keyword) ::
          :ok | {:error, any}
  def initialize(project_name, base_vault \\ nil, opts \\ []) do
    with :ok <- base_vault |> BaseVault.path!() |> create_vault(project_name, opts) do
      {:ok, project} = create_project(project_name)

      create_custom_prompt_template(project)

      if Keyword.get(opts, :code_sync, true) do
        CodeSync.sync(opts)
      else
        :ok
      end
    end
  end

  defp create_vault(base_vault, project_name, opts) do
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

      create_config(project_name, vault_dest_dir)

      create_gitignore_file(vault_dest_dir)

      copy_directory(@bin_dir, vault_dest_dir)

      :ok
    end
  end

  def create_config(project_name, vault_dest_dir \\ Vault.path()) do
    Magma.Config.template_path()
    |> copy_directory(vault_dest_dir)

    Magma.Config.System.path()
    |> create_file(Magma.Config.System.template(project_name))

    Vault.Index.index()
  end

  defp create_gitignore_file(vault_dest_dir) do
    vault_dest_dir
    |> Path.join(".gitignore")
    |> create_file("""
    #{Magma.PromptResult.dir()}/
    """)
  end

  defp create_project(project_name) do
    project_name
    |> Project.new!()
    |> Concept.create()
  end

  defp create_custom_prompt_template(project) do
    prompt =
      "default"
      |> Prompt.new!(generation: Generation.default())
      |> Document.init()

    Vault.custom_prompt_template_path()
    |> create_file(Prompt.Template.custom_prompt_obsidian_template(project, prompt))
  end
end

defmodule Magma.Vault.Initializer do
  alias Magma.Vault
  alias Magma.Vault.{BaseVault, CodeSync}
  alias Magma.Matter.{Project, Text}
  alias Magma.Concept
  alias Magma.Artefacts.TableOfContents

  import Magma.MixHelper

  def initialize(project_name, base_vault \\ nil, opts \\ []) do
    with :ok <- base_vault |> BaseVault.path!() |> create_vault(opts) do
      create_project(project_name)

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

  def create_text(text_name, text_type)

  def create_text(text_name, text_type_name) when is_binary(text_type_name) do
    if text_type = Text.type(text_type_name) do
      create_text(text_name, text_type)
    else
      {:error, "unknown text type: #{text_type}"}
    end
  end

  def create_text(text_name, text_type) when is_binary(text_name) and is_atom(text_type) do
    if Text.type?(text_type) do
      with {:ok, concept} <- text_name |> text_type.new() |> Concept.create(),
           {:ok, _toc_prompt} <- TableOfContents.create_prompt(concept) do
        {:ok, concept}
      end
    else
      {:error, "invalid text type: #{text_type}"}
    end
  end
end

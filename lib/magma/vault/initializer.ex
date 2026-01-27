defmodule Magma.Vault.Initializer do
  @moduledoc false

  alias Magma.Vault
  alias Magma.Vault.BaseVault
  alias Magma.{Prompt, Session, Document, Generation}
  alias Magma.CLI.FileOps

  import FileOps, only: [copy_directory: 2, create_file: 2]

  @spec initialize(base_vault :: BaseVault.theme() | Path.t() | nil, keyword) ::
          :ok | {:error, any}
  def initialize(base_vault \\ nil, opts \\ []) do
    with :ok <- base_vault |> BaseVault.path!() |> create_vault(opts) do
      create_custom_prompt_template()
      create_session_templates()
    end
  end

  defp create_vault(base_vault, opts) do
    vault_dest_dir = Vault.path()

    if File.exists?(vault_dest_dir) && !Keyword.get(opts, :force) do
      {:error, :vault_already_existing}
    else
      FileOps.create_directory(vault_dest_dir)

      Prompt.path_prefix()
      |> Vault.path()
      |> FileOps.create_directory()

      Session.path_prefix()
      |> Vault.path()
      |> FileOps.create_directory()

      Vault.session_response_directory()
      |> FileOps.create_directory()

      base_vault
      |> Path.join(".obsidian")
      |> copy_directory(vault_dest_dir)

      create_config()

      Magma.Vault.Version.save(Magma.version())

      create_gitignore_file(vault_dest_dir)

      :ok
    end
  end

  def create_config do
    Magma.Config.System.path()
    |> create_file(Magma.Config.System.template())

    Vault.Index.index()

    :ok
  end

  defp create_gitignore_file(vault_dest_dir) do
    vault_dest_dir
    |> Path.join(".gitignore")
    |> create_file("""
    # we ignore prompt results by default, feel free to version them by removing this
    #{Magma.PromptResult.dir()}/

    # Session response files are temporary and should not be versioned
    sessions/.responses/
    """)
  end

  def create_custom_prompt_template do
    prompt =
      "default"
      |> Prompt.new!(generation: Generation.default())
      |> Document.init()

    Vault.custom_prompt_template_path()
    |> create_file(Prompt.Template.custom_prompt_obsidian_template(prompt))

    :ok
  end

  def create_session_templates do
    session =
      "default"
      |> Session.new!(generation: Generation.default())
      |> Document.init()

    Vault.session_template_path()
    |> create_file(Session.Template.session_obsidian_template(session))

    Vault.session_continuation_template_path()
    |> create_file(Session.Template.session_continuation_obsidian_template())

    Vault.session_response_prompt_template_path()
    |> create_file(Session.Template.session_response_prompt_eex_template())

    :ok
  end
end

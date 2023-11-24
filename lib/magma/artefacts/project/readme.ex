defmodule Magma.Artefacts.Readme do
  use Magma.Artefact, matter: Magma.Matter.Project

  alias Magma.Matter.Project
  alias Magma.{Concept, Vault}

  @name "README"

  @impl true
  def default_name(_), do: @name

  @impl true
  def version_title(%Artefact.Version{artefact: %__MODULE__{}}), do: nil

  @impl true
  def create_version(%Artefact.Version{artefact: %__MODULE__{}} = version, opts) do
    {readme_path, opts} = Keyword.pop(opts, :readme_path, real_readme_path())

    version.path
    |> Path.dirname()
    |> Magma.MixHelper.create_directory()

    cond do
      Magma.MixHelper.create_file(readme_path, version.content, opts) ->
        with :ok <- File.ln_s(readme_path, version.path) do
          Vault.index(version)

          {:ok, version.path}
        end

      Keyword.get(opts, :ok_skipped, false) ->
        {:ok, version.path}

      true ->
        {:skipped, version}
    end
  end

  defp real_readme_path do
    Path.join(File.cwd!(), "README.md")
  end

  @impl true
  def trim_prompt_result_header?, do: false

  @impl true
  def relative_base_path(%__MODULE__{name: name, concept: %Concept{subject: %Project{}}}) do
    Path.join(Project.relative_generated_artefacts_path(), name)
  end

  @impl true
  def relative_version_path(
        %__MODULE__{name: name, concept: %Concept{subject: %Project{}}} = artefact
      ) do
    artefact
    |> relative_base_path()
    |> Path.join("#{name}.md")
  end
end

defmodule Magma.Artefacts.Readme do
  use Magma.Artefact, matter: Magma.Matter.Project

  alias Magma.Matter.Project
  alias Magma.{Concept, Vault}

  @name "README"

  @template :code.priv_dir(:magma) |> Path.join("README_TEMPLATE.md")

  @impl true
  def name(_), do: @name

  @impl true
  def version_title(%Artefact.Version{artefact: __MODULE__}), do: nil

  @impl true
  def create_version(%Artefact.Version{artefact: __MODULE__} = version, opts) do
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
  def system_prompt_task(_concept \\ nil) do
    """
    Your task is to generate a project README using the following template (without the surrounding Markdown block), replacing the content between {{ ... }} accordingly:

    ```markdown
    #{File.read!(@template)}
    ```
    """
    |> String.trim_trailing()
  end

  @impl true
  def request_prompt_task(concept) do
    """
    Generate a README for project '#{concept.subject.name}' according to its description and the following information:

    Hex package name: #{Project.app_name()}
    Repo URL: https://github.com/github_username/repo_name
    Documentation URL: https://hexdocs.pm/#{Project.app_name()}/
    Homepage URL:
    Demo URL:
    Logo path: logo.jpg
    Screenshot path:
    License: MIT License
    Contact: Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - your@email.com
    Acknowledgments:

    ("n/a" means not applicable and should result in a removal of the respective parts)
    """
    |> String.trim_trailing()
  end

  @impl true
  def trim_prompt_result_header?, do: false

  @impl true
  def relative_base_path(%Concept{subject: %Project{}}) do
    Path.join(Project.relative_generated_artefacts_path(), @name)
  end

  @impl true
  def relative_version_path(%Concept{} = concept) do
    concept
    |> relative_base_path()
    |> Path.join("#{name(concept)}.md")
  end
end

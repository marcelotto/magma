defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter}

  import Magma.Utils.Guards

  @type t :: %__MODULE__{}

  @impl true
  def build_name(concept), do: "ModuleDoc of #{concept.name}"

  def prompt_name(concept), do: "Prompt for #{build_name(concept)}"

  @impl true
  def build_prompt_path(%__MODULE__{concept: concept} = moduledoc) do
    moduledoc
    |> base_path()
    |> Path.join("#{prompt_name(concept)}.md")
  end

  @impl true
  def build_version_path(%__MODULE__{concept: concept} = moduledoc) do
    moduledoc
    |> base_path()
    |> Path.join("#{build_name(concept)}.md")
  end

  defp base_path(%__MODULE__{concept: %Concept{subject: %Matter.Module{name: module}}}) do
    Path.join(["modules" | Module.split(module)])
  end

  @impl true
  def init(%__MODULE__{} = moduledoc) do
    {:ok, moduledoc}
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new()
    |> Concept.new!()
    |> new!()
    |> Artefact.Version.build_path()
    |> case do
      {:ok, path} -> path
      _ -> nil
    end
  end

  def get(mod) do
    path = version_path(mod)

    if File.exists?(path) do
      path
      |> File.read!()
      |> String.split(~r{^\# }m, parts: 2)
      |> case do
        [_, stripped_content] ->
          case String.split(stripped_content, "\n", parts: 2) do
            [_, stripped_content] -> String.trim(stripped_content)
            _ -> raise "invalid ModuleDoc artefact version document: #{path}"
          end

        _ ->
          raise "invalid ModuleDoc artefact version document: #{path}"
      end
    end
  end
end

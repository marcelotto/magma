defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Concept, Matter}

  @type t :: %__MODULE__{}

  @impl true
  def build_name(concept), do: "ModuleDoc of #{concept.name}"

  def prompt_name(concept), do: "Prompt for #{build_name(concept)}"

  def base_path(%__MODULE__{concept: %Concept{subject: %Matter.Module{name: module}}}) do
    Path.join(["modules" | Module.split(module)])
  end

  @impl true
  def prompt_path(%__MODULE__{concept: concept} = moduledoc) do
    moduledoc
    |> base_path()
    |> Path.join("#{prompt_name(concept)}.md")
  end

  @impl true
  def version_path(%__MODULE__{concept: concept} = moduledoc) do
    moduledoc
    |> base_path()
    |> Path.join("#{build_name(concept)}.md")
  end

  @impl true
  def init(%__MODULE__{} = moduledoc) do
    {:ok, moduledoc}
  end
end

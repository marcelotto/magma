defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  @type t :: %__MODULE__{}

  @impl true
  def name(concept), do: "ModuleDoc of #{concept.name}"

  def prompt_name(concept), do: "Prompt for #{name(concept)}"

  @impl true
  def prompt_path(%__MODULE__{concept: concept}) do
    Path.join(["modules", concept.name, "moduledoc", "#{prompt_name(concept)}.md"])
  end

  @impl true
  def init(%__MODULE__{} = moduledoc) do
    {:ok, moduledoc}
  end
end

defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter, DocumentStruct}
  alias Magma.View

  import Magma.Utils.Guards

  # Remember to update the ModuleDoc.artefact.config.md file when changing this!
  @prompt_result_section_title "Moduledoc"
  def prompt_result_section_title, do: @prompt_result_section_title

  @impl true
  def default_name(concept), do: "ModuleDoc of #{concept.name}"

  @impl true
  def version_prologue(%Artefact.Version{artefact: %__MODULE__{}}) do
    """
    Ensure that the module documentation is under a "#{@prompt_result_section_title}" section, as the contents of this section is used for the `@moduledoc`.

    Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.
    """
    |> String.trim_trailing()
    |> View.callout("caution")
  end

  @impl true
  def trim_prompt_result_header?, do: false

  @impl true
  def relative_base_path(%__MODULE__{
        concept: %Concept{subject: %Matter.Module{name: module} = matter}
      }) do
    Path.join([Matter.Module.relative_base_path(matter) | Module.split(module)])
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new!()
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
      with {:ok, document_struct} <-
             path
             |> File.read!()
             |> Magma.DocumentStruct.parse() do
        if section =
             DocumentStruct.section_by_title(document_struct, @prompt_result_section_title) do
          section
          |> DocumentStruct.Section.to_markdown(header: false)
          |> String.trim()
        else
          raise "invalid ModuleDoc artefact version document at #{path}: no '#{@prompt_result_section_title}' section found"
        end
      else
        {:error, error} ->
          raise "invalid ModuleDoc artefact version document at #{path}: #{inspect(error)}"
      end
    end
  end
end

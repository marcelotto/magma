defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter}

  import Magma.Utils.Guards

  @impl true
  def name(concept), do: "ModuleDoc of #{concept.name}"

  @impl true
  def relative_base_path(%Concept{subject: %Matter.Module{name: module}}) do
    Path.join([Matter.Module.relative_base_path() | Module.split(module)])
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new!()
    |> Concept.new!()
    |> Artefact.Version.build_path(__MODULE__)
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

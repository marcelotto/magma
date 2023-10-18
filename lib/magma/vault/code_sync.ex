defmodule Magma.Vault.CodeSync do
  @moduledoc false

  alias Magma.Matter.Project
  alias Magma.{Vault, Concept, Matter}

  import Magma.Utils

  @spec sync(keyword) :: :ok | {:error, any}
  def sync(opts \\ []) do
    if File.exists?(Vault.path()) do
      # We must create all concepts first, since the moduledoc prompts require this to determine submodules (see Magma.Matter.Module.submodules/1)
      with {:ok, concepts} <-
             map_while_ok(
               modules(opts),
               &Concept.create(&1, [], Keyword.put(opts, :prompts, false))
             ),
           {:ok, _} <- flat_map_while_ok(concepts, &Concept.create_prompts(&1, opts)) do
        :ok
      end
    else
      {:error, :vault_not_existing}
    end
  end

  defp modules(opts) do
    all_public_modules = Project.modules()

    cond do
      Keyword.get(opts, :all, false) ->
        all_public_modules

      true ->
        Enum.reject(
          all_public_modules,
          &(&1 |> Matter.Module.concept_name() |> Vault.Index.get_document_path())
        )
    end
  end
end

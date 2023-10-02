defmodule Magma.Generation do
  alias Magma.Artefact

  import Magma.Utils.Guards

  @type options :: keyword

  @type t :: struct
  @type prompt :: binary
  @type system_prompt :: prompt
  @type result :: binary

  @callback execute(t(), Artefact.Prompt.t(), options) :: {:ok, result} | {:error, any}

  def default do
    Application.get_env(:magma, :default_generation, Magma.Generation.OpenAI)
  end

  def execute(%Artefact.Prompt{} = prompt) do
    execute(prompt.generation, prompt)
  end

  def execute(%generation_type{} = generation, %Artefact.Prompt{} = prompt, opts \\ []) do
    generation_type.execute(generation, prompt, opts)
  end

  @doc """
  Returns the generation module for the given string.

  ## Example

      iex> Magma.Generation.type("OpenAI")
      Magma.Generation.OpenAI

      iex> Magma.Generation.type("Mock")
      Magma.Generation.Mock

      iex> Magma.Generation.type("Vault")
      nil

      iex> Magma.Generation.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if Code.ensure_loaded?(module) and function_exported?(module, :execute, 3) do
      module
    end
  end

  @doc """
  Returns the short version of the `Magma.Generation` implementation name.

  This is used as the `magma_generation` value in the YAML frontmatter.

  ## Example

      iex> Magma.Generation.short_name(Magma.Generation.OpenAI)
      OpenAI

      iex> Magma.Generation.short_name(Magma.Generation.Bumblebee.TextGeneration.Llama)
      Bumblebee.TextGeneration.Llama

  """
  def short_name(%module{}), do: short_name(module)

  def short_name(module) when maybe_module(module) do
    case Module.split(module) do
      ["Magma", "Generation" | rest] -> Module.concat(rest)
      _ -> raise("invalid Magma.Generation: #{inspect(module)}")
    end
  end

  def extract_from_metadata(metadata) do
    {generation_type, custom_metadata} = Map.pop(metadata, :magma_generation_type)
    {generation_params, custom_metadata} = Map.pop(custom_metadata, :magma_generation_params)

    cond do
      !generation_type || !generation_params ->
        {:ok, nil, metadata}

      !generation_type ->
        {:error, "magma_generation_params without magma_generation_type"}

      !generation_params ->
        {:error, "magma_generation_type without magma_generation_params"}

      generation_module = type(generation_type) ->
        with {:ok, generation} <- generation_module.new(generation_params) do
          {:ok, generation, custom_metadata}
        end

      true ->
        {:error, "invalid magma_generation_type type: #{generation_type}"}
    end
  end
end

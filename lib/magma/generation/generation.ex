defmodule Magma.Generation do
  @moduledoc """
  Generic adapter-based `Magma.Prompt` execution.

  The `Magma.Generation` module is primarily responsible for handling the
  execution of prompts. It is designed to be adaptable and flexible,
  supporting different LLMs via specific adapters.
  The module defines a behaviour that each adapter should implement,
  ensuring a consistent interface for executing prompts.

  The currently implemented adapters are:

  - `Magma.Generation.OpenAI` for the OpenAI API
  - `Magma.Generation.Manual` for manual prompt execution

  The default values for the generation specification embedded within a prompt
  document (the `magma_generation_type` and `magma_generation_params` properties
  in its YAML frontmatter) can be configured for your application in `config.exs`
  like this:

      config :magma,
        default_generation: Magma.Generation.OpenAI

      config :magma, Magma.Generation.OpenAI,
        model: "gpt-4",
        temperature: 0.6
  """

  alias Magma.{Artefact, View}

  import Magma.Utils.Guards

  @type options :: keyword

  @type t :: struct
  @type prompt :: binary
  @type system_prompt :: prompt
  @type result :: binary

  @callback execute(t(), Artefact.Prompt.t(), options) :: {:ok, result} | {:error, any}

  def default do
    Application.get_env(
      :magma,
      :default_generation,
      if(Code.ensure_loaded?(Magma.Generation.OpenAI),
        do: Magma.Generation.OpenAI,
        else: Magma.Generation.Manual
      )
    )
  end

  def execute(prompt) when is_prompt(prompt) do
    execute(prompt.generation, prompt)
  end

  def execute(%generation_type{} = generation, prompt, opts \\ []) when is_prompt(prompt) do
    generation_type.execute(generation, prompt, opts)
  end

  @doc """
  Returns the generation module for the given string.

  ## Example

      iex> Magma.Generation.type("OpenAI")
      Magma.Generation.OpenAI

      iex> Magma.Generation.type("Manual")
      Magma.Generation.Manual

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

  @doc """
  Renders generation YAML frontmatter properties.
  """
  def render_front_matter(%_generation_type{} = generation) do
    """
    magma_generation_type: #{inspect(short_name(generation))}
    magma_generation_params: #{View.yaml_nested_map(generation)}
    """
    |> String.trim_trailing()
  end

  @doc """
  Extracts generation information from YAML frontmatter metadata.

  The function attempts to retrieve the `magma_generation_type` and
  `magma_generation_params` from the metadata. It returns a tuple containing
  the generation (if found and valid), and the remaining metadata.
  """
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

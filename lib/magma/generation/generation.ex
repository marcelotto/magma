defmodule Magma.Generation do
  @type options :: keyword

  @type t :: struct
  @type prompt :: binary
  @type system_prompt :: prompt
  @type result :: binary

  @callback execute(t(), prompt, system_prompt, keyword) :: {:ok, result} | {:error, any}

  def default do
    Application.fetch_env!(:magma, :default_generation)
  end

  @doc """
  Returns the generation module for the given string.

  ## Example

      iex> Magma.Generation.type("Mock")
      Magma.Generation.Mock

      iex> Magma.Generation.type("Vault")
      nil

      iex> Magma.Generation.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(__MODULE__, string)

    if Code.ensure_loaded?(module) and function_exported?(module, :execute, 4) do
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

  def short_name(module) when is_atom(module) do
    case Module.split(module) do
      ["Magma", "Generation" | rest] -> Module.concat(rest)
      _ -> raise("invalid Magma.Generation: #{inspect(module)}")
    end
  end
end
defmodule Magma.Generation.Mock do
  @behaviour Magma.Generation

  defstruct result: :foo, expected_prompt: nil, expected_system_prompt: nil

  def new(params \\ []) do
    {:ok, new!(params)}
  end

  def new!(params \\ []) do
    struct(__MODULE__, params)
  end

  def execute(generation, prompt, system_prompt \\ nil, opts \\ [])

  def execute(
        %__MODULE__{expected_prompt: nil, expected_system_prompt: nil} = generation,
        _prompt,
        _system_prompt,
        _opts
      ) do
    {:ok, generation.result}
  end

  def execute(
        %__MODULE__{expected_prompt: prompt, expected_system_prompt: system_prompt} = generation,
        prompt,
        system_prompt,
        _opts
      ) do
    {:ok, generation.result}
  end
end

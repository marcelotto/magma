defmodule Magma.Generation.Mock do
  @behaviour Magma.Generation

  alias Magma.Prompt.Assembler

  import Magma.Utils.Guards

  defstruct result: "foo", expected_prompt: nil, expected_system_prompt: nil

  def new(params \\ []) do
    {:ok, new!(params)}
  end

  def new!(params \\ []) do
    struct(__MODULE__, params)
  end

  @impl true
  def execute(generation, prompt, opts \\ [])

  def execute(%__MODULE__{} = generation, prompt, _opts) when is_prompt(prompt) do
    with {:ok, system_prompt, request_prompt} <- Assembler.assemble_parts(prompt) do
      execute(generation, request_prompt, system_prompt)
    end
  end

  def execute(
        %__MODULE__{expected_prompt: nil, expected_system_prompt: nil} = generation,
        _prompt,
        _system_prompt
      ) do
    {:ok, generation.result}
  end

  def execute(
        %__MODULE__{expected_prompt: prompt, expected_system_prompt: system_prompt} = generation,
        prompt,
        system_prompt
      ) do
    {:ok, generation.result}
  end
end

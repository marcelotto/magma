defmodule Magma.Generation.OpenAI do
  @behaviour Magma.Generation

  defstruct model: "gpt-3.5-turbo",
            temperature: 0.2

  require Logger

  defp default_params, do: Application.get_env(:magma, __MODULE__, [])

  def new(params \\ [])

  def new(params) when is_map(params) do
    params |> Keyword.new() |> new()
  end

  def new(params) do
    {:ok, struct(__MODULE__, Keyword.merge(default_params(), params))}
  end

  def new!(params \\ []) do
    case new(params) do
      {:ok, open_ai} -> open_ai
      {:error, error} -> raise error
    end
  end

  def execute(%__MODULE__{} = generation, prompt, system_prompt \\ nil) do
    Logger.info("Executing OpenAI chat completion...")

    generation
    |> Map.from_struct()
    |> Keyword.new()
    |> Keyword.put(:messages, prompt_messages(prompt, system_prompt))
    |> OpenAI.chat_completion()
    |> case do
      {:ok,
       %{
         choices: [%{"finish_reason" => "length", "message" => %{"content" => _result}}],
         usage: %{
           "completion_tokens" => completion_tokens,
           "prompt_tokens" => prompt_tokens,
           "total_tokens" => total_tokens
         }
       }} ->
        Logger.error(
          "OpenAI chat completion with model #{generation.model} token limit exceeded: #{prompt_tokens} + #{completion_tokens} = #{total_tokens} tokens"
        )

        {:error, :token_limit_exceeded}

      {:ok,
       %{
         choices: [%{"finish_reason" => "stop", "message" => %{"content" => result}}],
         usage: %{
           "completion_tokens" => completion_tokens,
           "prompt_tokens" => prompt_tokens,
           "total_tokens" => total_tokens
         }
       }} ->
        Logger.info(
          "Finished OpenAI chat completion (#{prompt_tokens} + #{completion_tokens} = #{total_tokens} tokens)"
        )

        {:ok, result}

      {:error, _} = error ->
        error
    end
  end

  defp prompt_messages(prompt, nil) do
    [
      %{role: "user", content: prompt}
    ]
  end

  defp prompt_messages(prompt, system_prompt) do
    [
      %{role: "system", content: system_prompt},
      %{role: "user", content: prompt}
    ]
  end
end
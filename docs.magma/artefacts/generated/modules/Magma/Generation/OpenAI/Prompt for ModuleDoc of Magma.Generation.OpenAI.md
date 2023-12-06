---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Generation.OpenAI]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:55
tags: [magma-vault]
aliases: []
---

**Generated results**

```dataview
TABLE
	tags AS Tags,
	magma_generation_type AS Generator,
	magma_generation_params AS Params
WHERE magma_prompt = [[]]
```

Final version: [[ModuleDoc of Magma.Generation.OpenAI]]

**Actions**

```button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
```
```button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
```
```button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
```
```button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
```

# Prompt for ModuleDoc of Magma.Generation.OpenAI

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Magma.Generation.OpenAI#Context knowledge|]]


## Request

![[Magma.Generation.OpenAI#ModuleDoc prompt task|]]

### Description of the module `Magma.Generation.OpenAI` ![[Magma.Generation.OpenAI#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
if Code.ensure_loaded?(OpenAI) do
  defmodule Magma.Generation.OpenAI do
    use Magma.Generation

    alias Magma.Prompt.Assembler

    defstruct model: "gpt-4",
              temperature: 0.6

    import Magma.Utils.Guards

    require Logger

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

    @impl true
    def execute(%__MODULE__{} = generation, prompt, _opts \\ []) when is_prompt(prompt) do
      Logger.info("Executing OpenAI chat completion...")

      with {:ok, system_prompt, request_prompt} <- Assembler.assemble_parts(prompt) do
        generation
        |> Map.from_struct()
        |> Keyword.new()
        |> Keyword.put(:messages, prompt_messages(request_prompt, system_prompt))
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

            # TODO: handle this
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
end

```

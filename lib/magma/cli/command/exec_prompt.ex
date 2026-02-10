defmodule Magma.CLI.Command.ExecPrompt do
  @moduledoc "CLI command to execute a prompt or session via LLM."

  use Magma.CLI.Command

  alias Magma.{Generation, PromptResult}
  alias Magma.Document.Loader

  @impl true
  def name, do: "exec-prompt"

  @impl true
  def description, do: "Execute a prompt via LLM"

  @options [
    manual: :boolean,
    interactive: :boolean,
    trim_header: :boolean
  ]

  @impl true
  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] ->
        {:error, "prompt name or path missing"}

      opts, [prompt_name] ->
        {attrs, opts} =
          case Keyword.pop(opts, :manual, false) do
            {true, opts} -> {[generation: Generation.Manual.new!()], opts}
            {_, opts} -> {[], opts}
          end

        Loader.with_prompt(prompt_name, &PromptResult.create(&1, attrs, opts))
    end)
  end
end

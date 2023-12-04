defmodule Mix.Tasks.Magma.Prompt.Update do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Artefact, Document, Vault}

  @shortdoc "Regenerates a artefact prompt"

  @options [
    all: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      [all: true], [] -> update_all()
      _opts, [] -> error("prompt name or path missing")
      _opts, [prompt_name] -> update(prompt_name)
    end)
  end

  def update_all do
    Enum.each(all_prompt_files(), &update/1)
  end

  def update(name) do
    with {:ok, prompt} <- Artefact.Prompt.load(name),
         {:ok, _} <- Document.recreate(prompt) do
      :ok
    end
    |> handle_error()
  end

  def all_prompt_files(path \\ Vault.artefact_generation_path()) do
    path
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      path = Path.join(path, entry)

      cond do
        entry == Magma.PromptResult.dir() -> []
        entry == Magma.Text.Preview.dir() -> []
        File.dir?(path) -> all_prompt_files(path)
        Path.extname(path) == ".md" -> [path]
        true -> []
      end
    end)
  end
end

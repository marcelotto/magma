defmodule Mix.Tasks.Magma.Text.Assemble do
  @shortdoc "Generates the section concepts from the final table of contents"
  @moduledoc @shortdoc

  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Concept, Artefact}
  alias Magma.Document.Loader
  alias Magma.Artefacts.TableOfContents
  alias Magma.Text.Assembler

  @options [
    force: :boolean
  ]

  def run(args) do
    Mix.Task.run("app.start")

    with_valid_options(args, @options, fn
      _opts, [] -> Mix.shell().error("concept or toc name missing")
      opts, [concept_or_toc_name] -> assemble_toc!(concept_or_toc_name, opts)
    end)
  end

  defp assemble_toc!(concept_or_toc_name, opts) when is_binary(concept_or_toc_name) do
    with {:ok, document} <- Loader.load(concept_or_toc_name),
         {:ok, _} <- assemble_toc(document, opts) do
      :ok
    else
      {:error, error} -> raise error
    end
  end

  def assemble_toc(%Concept{} = concept, opts) do
    concept
    |> TableOfContents.load_version!()
    |> assemble_toc(opts)
  end

  def assemble_toc(%Artefact.Version{} = version, opts) do
    Assembler.assemble(version, opts)
  end

  def assemble_toc(%invalid_document_type{path: path}, _) do
    raise Magma.InvalidDocumentType.exception(
            document: path,
            expected: [Concept, Artefact.Version],
            actual: invalid_document_type
          )
  end
end

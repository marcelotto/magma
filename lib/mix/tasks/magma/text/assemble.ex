defmodule Mix.Tasks.Magma.Text.Assemble do
  use Magma
  use Mix.Task

  import Magma.MixHelper

  alias Magma.{Concept, Artefact}
  alias Magma.Document.Loader
  alias Magma.Artefacts.TableOfContents
  alias Magma.Text.Assembler

  @shortdoc "Generates the documents for the sections of a text"

  @options [
    force: :boolean
  ]

  @requirements ["app.start"]

  def run(args) do
    with_valid_options(args, @options, fn
      _opts, [] -> error("concept or toc name missing")
      opts, [concept_or_toc_name] -> assemble_toc!(concept_or_toc_name, opts)
    end)
  end

  defp assemble_toc!(concept_or_toc_name, opts) when is_binary(concept_or_toc_name) do
    with {:ok, document} <- Loader.load(concept_or_toc_name),
         {:ok, _} <- assemble_toc(document, opts) do
      :ok
    else
      error -> handle_error(error)
    end
  end

  defp assemble_toc(%Concept{} = concept, opts) do
    concept
    |> TableOfContents.new!()
    |> Artefact.Version.new!()
    |> Artefact.Version.load()
    |> assemble_toc(opts)
  end

  defp assemble_toc(%Artefact.Version{} = version, opts) do
    Assembler.assemble(version, opts)
  end

  defp assemble_toc(%invalid_document_type{path: path}, _) do
    {:error,
     raise(
       Magma.InvalidDocumentType.exception(
         document: path,
         expected: [Concept, Artefact.Version],
         actual: invalid_document_type
       )
     )}
  end
end

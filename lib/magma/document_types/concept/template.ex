defmodule Magma.Concept.Template do
  use Magma.Document.Template

  alias Magma.{Vault, Concept}

  require Concept

  @path Magma.Document.template_path() |> Path.join("concept")

  @impl true
  def render(concept, assigns \\ [])

  @path
  |> File.ls!()
  |> Enum.reject(&match?("." <> _, &1))
  |> Enum.map(&Path.join(@path, &1))
  |> Enum.each(fn file ->
    case Vault.document_type(file) do
      {:ok, Concept, matter_type} ->
        @external_resource file
        def render(%Concept{subject: %unquote(matter_type){} = subject} = concept, assigns) do
          if false do
            # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
            concept || subject || assigns
          else
            unquote(EEx.compile_file(file))
          end
        end

      {:ok, document_type, _} ->
        raise "invalid magma_type in Artefact.Prompt template at #{file}: #{document_type}"

      {:error, error} ->
        raise error
    end
  end)

  def link_to_prompt(concept, artefact) do
    concept
    |> artefact.prompt!()
    |> link_to()
  end
end

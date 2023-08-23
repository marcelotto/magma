defmodule Magma.Concept.Template do
  use Magma.Document.Template

  alias Magma.{Vault, Concept, Artefact}

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
        def render(%Concept{subject: %unquote(matter_type){} = matter} = concept, assigns) do
          # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
          if false do
            concept || matter || assigns
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

  def transclude_prompt(concept, artefact) do
    prompt = concept |> artefact.new!() |> Artefact.Prompt.new!()

    """
    > [!NOTE] #{link_to(prompt)}
    > #{transclude(prompt)}
    """
    |> String.trim_trailing()
  end
end

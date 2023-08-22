defmodule Magma.Concept.Template do
  use Magma.Document.Template

  alias Magma.{Concept, Matter, Artefact}

  @path Magma.Document.template_path() |> Path.join("concept")

  @impl true
  def render(concept, assigns \\ [])

  @path
  |> File.ls!()
  |> Enum.reject(&match?("." <> _, &1))
  |> Enum.map(&Path.join(@path, &1))
  |> Enum.each(fn file ->
    {:ok, metadata, _body} = YamlFrontMatter.parse_file(file)

    if metadata["magma_type"] != "Concept" do
      raise "invalid Artefact.Prompt template at #{file} with magma_type #{metadata["magma_type"]}"
    end

    matter_type = Module.concat(Matter, Map.fetch!(metadata, "magma_matter"))

    @external_resource file
    def render(%Concept{subject: %unquote(matter_type){} = matter} = concept, assigns) do
      # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
      if false do
        concept || matter || assigns
      else
        unquote(EEx.compile_file(file))
      end
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

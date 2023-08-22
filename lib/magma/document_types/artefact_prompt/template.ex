defmodule Magma.Artefact.Prompt.Template do
  use Magma.Document.Template
  alias Magma.Artefact

  @path Magma.Document.template_path() |> Path.join("artefact_prompt")

  @impl true
  def render(artefact_prompt, assigns \\ [])

  @path
  |> File.ls!()
  |> Enum.reject(&match?("." <> _, &1))
  |> Enum.map(&Path.join(@path, &1))
  |> Enum.flat_map(fn directory ->
    directory
    |> File.ls!()
    |> Enum.reject(&match?("." <> _, &1))
    |> Enum.map(&Path.join(directory, &1))
  end)
  |> Enum.each(fn file ->
    {:ok, metadata, _body} = YamlFrontMatter.parse_file(file)

    if metadata["magma_type"] != "Artefact.Prompt" do
      raise "invalid Artefact.Prompt template at #{file} with magma_type #{metadata["magma_type"]}"
    end

    artefact_type = Module.concat(Magma.Artefacts, Map.fetch!(metadata, "magma_artefact"))

    @external_resource file
    def render(
          %Artefact.Prompt{artefact: %unquote(artefact_type){} = artefact} = prompt,
          assigns
        ) do
      if false do
        # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
        prompt || artefact || assigns
      else
        unquote(EEx.compile_file(file))
      end
    end
  end)
end

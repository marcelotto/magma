defmodule Magma.Concept.Template do
  use Magma.Document.Template

  alias Magma.{Concept, Matter}

  require Concept

  @path Magma.Document.template_path() |> Path.join("concept")

  @impl true
  def render(concept, assigns \\ [])

  @path
  |> File.ls!()
  |> Enum.reject(&match?("." <> _, &1))
  |> Enum.map(&Path.join(@path, &1))
  |> Enum.each(fn file ->
    if matter_type =
         file
         |> Path.basename(Path.extname(file))
         |> Matter.type() do
      @external_resource file
      def render(%Concept{subject: %unquote(matter_type){} = subject} = concept, assigns) do
        if false do
          # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
          concept || subject || assigns
        else
          unquote(EEx.compile_file(file))
        end
      end
    else
      raise "unable to detect matter type of #{file}"
    end
  end)

  def link_to_prompt(concept, artefact) do
    concept
    |> artefact.prompt!()
    |> link_to()
  end
end

defmodule Magma.Artefact.Prompt.Template do
  use Magma.Document.Template

  alias Magma.Artefact
  alias Magma.DocumentStruct.Section
  alias Magma.Matter.Project

  import Magma.Matter.Module, only: [code: 1]

  import Magma.Concept,
    only: [description: 1, artefact_system_prompt: 2]

  require Artefact.Prompt

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
    if artefact_type =
         file
         |> Path.basename(Path.extname(file))
         |> Artefact.type() do
      @external_resource file
      def render(
            %Artefact.Prompt{artefact: unquote(artefact_type) = artefact, concept: concept} =
              prompt,
            assigns
          ) do
        subject = concept.subject
        project = Project.concept()

        if false do
          # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
          prompt || artefact || concept || subject || project || assigns
        else
          unquote(EEx.compile_file(file))
        end
      end
    else
      raise "unable to detect artefact type of #{file}"
    end
  end)

  defp include(nil, _), do: nil
  defp include(section, opts), do: Section.to_string(section, opts) |> String.trim()

  defp controls do
    """
    **Generated results**

    #{prompt_results_table()}

    **Actions**

    #{button("Execute", "magma.prompt.exec", color: "blue")}
    #{button("Update", "magma.prompt.update")}
    """
    |> String.trim_trailing()
  end
end

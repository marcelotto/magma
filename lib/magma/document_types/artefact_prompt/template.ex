defmodule Magma.Artefact.Prompt.Template do
  use Magma.Document.Template

  alias Magma.{Vault, Artefact}

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
    case Vault.document_type(file) do
      {:ok, Artefact.Prompt, artefact_type} ->
        @external_resource file
        def render(
              %Artefact.Prompt{artefact: %unquote(artefact_type){} = artefact} = prompt,
              assigns
            ) do
          concept = artefact.concept
          subject = concept.subject

          if false do
            # this never-taken branch is a hack to circumvent falsely claimed unused variable warnings
            prompt || artefact || concept || subject || assigns
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
end
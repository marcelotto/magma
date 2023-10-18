defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter, DocumentStruct}
  alias Magma.View

  import Magma.Utils.Guards

  @prompt_result_section_title "Moduledoc"
  def prompt_result_section_title, do: @prompt_result_section_title

  @impl true
  def name(concept), do: "ModuleDoc of #{concept.name}"

  @impl true
  def system_prompt_task(_concept) do
    """
    Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

    ```markdown
    ## #{@prompt_result_section_title}

    The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

    Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


    ## Function docs

    In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

    ### `function/1`

    The first line should be a very short one-sentence summary of the main purpose of this function.

    Then follows the main body of the function documentation.
    ```

    #{View.comment("You can edit this prompt, as long you ensure the moduledoc is generated in a section named '#{@prompt_result_section_title}', as the contents of this section is used for the @moduledoc.")}

    """
    |> String.trim_trailing()
  end

  @impl true
  def request_prompt_task(concept) do
    """
    Generate documentation for module `#{concept.name}` according to its description and code in the knowledge base below.
    """
    |> String.trim_trailing()
  end

  @impl true
  def version_prologue(%Artefact.Version{artefact: __MODULE__}) do
    """
    Ensure that the module documentation is under a "#{@prompt_result_section_title}" section, as the contents of this section is used for the `@moduledoc`.

    Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.
    """
    |> String.trim_trailing()
    |> View.callout("caution")
  end

  @impl true
  def trim_prompt_result_header?, do: false

  @impl true
  def relative_base_path(%Concept{subject: %Matter.Module{name: module} = matter}) do
    Path.join([Matter.Module.relative_base_path(matter) | Module.split(module)])
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new!()
    |> Concept.new!()
    |> Artefact.Version.build_path(__MODULE__)
    |> case do
      {:ok, path} -> path
      _ -> nil
    end
  end

  def get(mod) do
    path = version_path(mod)

    if File.exists?(path) do
      with {:ok, document_struct} <-
             path
             |> File.read!()
             |> Magma.DocumentStruct.parse() do
        if section =
             DocumentStruct.section_by_title(document_struct, @prompt_result_section_title) do
          section
          |> DocumentStruct.Section.to_markdown(header: false)
          |> String.trim()
        else
          raise "invalid ModuleDoc artefact version document at #{path}: no '#{@prompt_result_section_title}' section found"
        end
      else
        {:error, error} ->
          raise "invalid ModuleDoc artefact version document at #{path}: #{inspect(error)}"
      end
    end
  end
end

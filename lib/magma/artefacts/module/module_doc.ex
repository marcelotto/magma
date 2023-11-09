defmodule Magma.Artefacts.ModuleDoc do
  use Magma.Artefact, matter: Magma.Matter.Module

  alias Magma.{Artefact, Concept, Matter, DocumentStruct}
  alias Magma.View

  import Magma.Utils.Guards

  @prompt_result_section_title "Moduledoc"
  def prompt_result_section_title, do: @prompt_result_section_title

  @impl true
  def default_name(concept), do: "ModuleDoc of #{concept.name}"

  @impl true
  def system_prompt_task(_concept \\ nil) do
    """
    You have two tasks to do based on the given implementation of the module and your knowledge base:

    1. generate the content of the `@doc` strings of the public functions
    2. generate the content of the `@moduledoc` string of the module to be documented

    Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

    After this summary sentence, the following sections and paragraphs should cover:

    - What's the purpose of this module/function?
    - For moduledocs: What are the main function(s) of this module?
    - If possible, an example usage in an "Example" section using an indented code block
    - configuration options (if there are any)
    - everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

    The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

    ```markdown
    ## Function docs

    ### `function/1`

    Summary sentence

    Body

    ## #{@prompt_result_section_title}

    Summary sentence

    Body
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
  def version_prologue(%Artefact.Version{artefact: %__MODULE__{}}) do
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
  def relative_base_path(%__MODULE__{
        concept: %Concept{subject: %Matter.Module{name: module} = matter}
      }) do
    Path.join([Matter.Module.relative_base_path(matter) | Module.split(module)])
  end

  # We can not use the Magma.Vault.Index here because this function will be used also at compile-time.
  def version_path(mod) when maybe_module(mod) do
    mod
    |> Matter.Module.new!()
    |> Concept.new!()
    |> new!()
    |> Artefact.Version.build_path()
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

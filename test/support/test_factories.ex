defmodule Magma.TestFactories do
  @moduledoc """
  Test factories.
  """

  alias Magma.{
    Concept,
    Matter,
    Artefact,
    Artefacts,
    DocumentStruct
  }

  def datetime, do: ~U[2023-08-09 15:16:02.255559Z]

  def datetime(amount_to_add, unit \\ :second),
    do: datetime() |> DateTime.add(amount_to_add, unit)

  def project_matter do
    Matter.Project.new!("Magma")
  end

  def module_matter(mod \\ Nested.Example) do
    Matter.Module.new!(mod)
  end

  def project_concept do
    project_matter()
    |> Concept.new!()
  end

  def module_concept(mod \\ Nested.Example) do
    mod
    |> module_matter()
    |> Concept.new!()
  end

  def module_doc_artefact_prompt(mod \\ Nested.Example) do
    mod
    |> module_concept()
    |> Artefacts.ModuleDoc.prompt!()
  end

  def module_doc_artefact_prompt_result(mod \\ Nested.Example) do
    mod
    |> module_doc_artefact_prompt()
    |> Artefact.PromptResult.new!()
  end

  def content_without_subsections do
    """
    ## Example title

    Foo
    """
  end

  def content_with_subsections do
    """
    ## Example title

    Foo

    ### Subsection 1

    Labore enim excepteur aute veniam.

    #### Subsection 1.2

    Lorem consequat amet minim pariatur, dolore ut.

    ### Subsection 2

    Nisi do voluptate esse culpa sint.
    """
  end

  def document_struct(:without_subsections), do: document_struct(content_without_subsections())
  def document_struct(:with_subsections), do: document_struct(content_with_subsections())

  def document_struct(content) do
    {:ok, document_struct} = DocumentStruct.parse(content)
    document_struct
  end

  def section(content) do
    case document_struct(content) do
      %DocumentStruct{sections: [section]} -> section
    end
  end
end

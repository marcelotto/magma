defmodule Magma.TestFactories do
  @moduledoc """
  Test factories.
  """

  alias Magma.{
    Concept,
    Matter,
    Artefacts,
    Prompt,
    PromptResult,
    DocumentStruct
  }

  def datetime, do: ~U[2023-08-09 15:16:02.255559Z]

  def datetime(amount_to_add, unit \\ :second),
    do: datetime() |> DateTime.add(amount_to_add, unit)

  def project_matter(name \\ "Some") do
    Matter.Project.new!(name)
  end

  def module_matter(mod \\ Nested.Example) do
    Matter.Module.new!(mod)
  end

  def user_guide_matter(name \\ "Some User Guide") do
    Matter.Text.new!(Matter.Texts.UserGuide, name)
  end

  def user_guide_section_matter(section_name \\ "Introduction", text_name \\ "Some User Guide") do
    Matter.Text.new!(Matter.Texts.UserGuide, text_name)
    |> Matter.Text.Section.new!(section_name)
  end

  def project_concept(name \\ "Some") do
    name
    |> project_matter()
    |> Concept.new!()
  end

  def module_concept(mod \\ Nested.Example) do
    mod
    |> module_matter()
    |> Concept.new!()
  end

  def user_guide_concept(name \\ "Some User Guide") do
    name
    |> user_guide_matter()
    |> Concept.new!()
  end

  def user_guide_section_concept(section_name \\ "Introduction", text_name \\ "Some User Guide") do
    section_name
    |> user_guide_section_matter(text_name)
    |> Concept.new!()
  end

  def prompt(name \\ "Foo-Prompt") do
    Prompt.new!(name)
  end

  def module_doc_artefact_prompt(mod \\ Nested.Example) do
    mod
    |> module_concept()
    |> Artefacts.ModuleDoc.prompt!()
  end

  def user_guide_toc_prompt(name \\ "Some User Guide") do
    name
    |> user_guide_concept()
    |> Artefacts.TableOfContents.prompt!()
  end

  def module_doc_artefact_prompt_result(mod \\ Nested.Example) do
    mod
    |> module_doc_artefact_prompt()
    |> PromptResult.new!()
  end

  def custom_artefact_prompt(system_prompt, request_prompt) do
    module_doc_artefact_prompt()
    |> set_prompt_content(system_prompt, request_prompt)
  end

  def custom_prompt(system_prompt, request_prompt) do
    prompt()
    |> set_prompt_content(system_prompt, request_prompt)
  end

  defp set_prompt_content(%prompt_type{} = prompt, system_prompt, request_prompt) do
    %{
      prompt
      | content: """
        #{Prompt.Template.controls(prompt)}

        # #{prompt_type.title(prompt)}

        ## #{Prompt.Template.system_prompt_section_title()}

        #{system_prompt}

        ## #{Prompt.Template.request_prompt_section_title()}

        #{request_prompt}
        """
    }
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

defmodule Magma.TestFactories do
  @moduledoc """
  Test factories.
  """

  alias Magma.{Prompt, DocumentStruct}

  def datetime, do: ~U[2023-08-09 15:16:02.255559Z]

  def datetime(amount_to_add, unit \\ :second),
    do: datetime() |> DateTime.add(amount_to_add, unit)

  def naive_datetime, do: ~N[2023-10-04 13:25:47]

  def native_datetime(amount_to_add, unit \\ :second),
    do: naive_datetime() |> NaiveDateTime.add(amount_to_add, unit)

  def prompt(name \\ "Foo-Prompt") do
    Prompt.new!(name)
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

defmodule Magma.Text.Assembler do
  alias Magma.{Concept, Matter, Artefact, Document, DocumentStruct}
  alias Magma.Text.Preview
  alias Magma.Artefacts.TableOfContents
  alias Magma.View

  import Magma.Utils, only: [map_while_ok: 2, flat_map_while_ok: 2]

  def assemble(%Artefact.Version{artefact: TableOfContents} = version, opts \\ []) do
    {artefacts_to_assemble, opts} = extract_assemble_artefacts(opts)

    with {:ok, document_struct} <- DocumentStruct.parse(version.content),
         sections_with_abstracts =
           sections_with_abstracts(document_struct, version.concept.subject),
         {:ok, section_concepts} <-
           create_section_concepts(sections_with_abstracts, opts),
         {:ok, concept} <-
           update_concept(version.concept, sections_with_abstracts),
         {:ok, _updated_version} <-
           replace_assemble_button(version),
         {:ok, _prompts} <-
           create_section_artefact_prompts(section_concepts, artefacts_to_assemble, opts),
         {:ok, _previews} <-
           create_artefact_previews(concept, artefacts_to_assemble, opts) do
      {:ok, concept}
    end
  end

  defp sections_with_abstracts(document_struct, main_text) do
    Enum.map(DocumentStruct.main_section(document_struct).sections, fn section ->
      {
        Matter.Text.Section.new!(main_text, section.title),
        section
        |> DocumentStruct.Section.to_string(header: false)
        |> String.trim()
      }
    end)
  end

  defp create_section_concepts(sections_with_abstracts, opts) do
    opts = Keyword.put_new(opts, :ok_skipped, true)
    map_while_ok(sections_with_abstracts, &create_section_concept(&1, opts))
  end

  defp create_section_concept({section_matter, abstract}, opts) do
    Concept.create(section_matter, [], Keyword.put(opts, :assigns, abstract: abstract))
  end

  defp update_concept(%Concept{sections: sections} = concept, sections_with_abstracts) do
    with {:ok, section} <- text_concept_sections_section(sections_with_abstracts) do
      sections_title = Matter.Text.sections_section_title()
      destination_index = Enum.find_index(sections, &match?(%{title: ^sections_title}, &1))

      %Concept{concept | sections: List.replace_at(sections, destination_index, section)}
      |> Concept.update_content_from_ast()
      |> Document.save()
    end
  end

  defp text_concept_sections_section(sections_with_abstracts) do
    with {:ok, %DocumentStruct{sections: [section]}} <-
           DocumentStruct.parse(
             """
             # #{Matter.Text.sections_section_title()}

             """ <>
               Enum.map_join(sections_with_abstracts, "\n", fn {section_matter, _} ->
                 section_concept_name = Matter.Text.Section.concept_name(section_matter)

                 """
                 ## #{View.link_to(section_concept_name, section_matter.name)} #{View.transclude(section_concept_name, Concept.description_section_title())}
                 """
               end)
           ) do
      {:ok, section}
    end
  end

  defp replace_assemble_button(%Artefact.Version{} = version) do
    %Artefact.Version{
      version
      | content:
          String.replace(
            version.content,
            TableOfContents.assemble_button(),
            TableOfContents.assemble_callout(version)
          )
    }
    |> Document.save()
  end

  defp extract_assemble_artefacts(opts) do
    case Keyword.pop(opts, :artefacts, :all) do
      {false, opts} -> {[], opts}
      {:all, opts} -> {Matter.Text.Section.artefacts(), opts}
      {artefacts, opts} -> {List.wrap(artefacts), opts}
    end
  end

  defp create_artefact_previews(concept, artefacts_to_assemble, opts) do
    opts = Keyword.put_new(opts, :force, true)
    map_while_ok(artefacts_to_assemble, &Preview.create(concept, &1, [], opts))
  end

  defp create_section_artefact_prompts(section_concepts, artefacts_to_assemble, opts) do
    opts = Keyword.put_new(opts, :force, true)

    flat_map_while_ok(section_concepts, fn section_concept ->
      map_while_ok(artefacts_to_assemble, &Artefact.Prompt.create(section_concept, &1, [], opts))
    end)
  end
end

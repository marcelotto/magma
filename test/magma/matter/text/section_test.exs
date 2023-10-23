defmodule Magma.Matter.Text.SectionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Matter.Text.Section

  alias Magma.Concept

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide.md",
         "concepts/Project.md"
       ]
  test "Concept creation and loading" do
    section_matter = user_guide_section_matter()
    text_title = section_matter.main_text.name
    section_title = section_matter.name
    section_name = "#{text_title} - #{section_title}"
    abstract = "An abstract of the introduction"

    expected_path =
      Vault.path("concepts/texts/#{text_title}/#{section_name}.md")

    refute File.exists?(expected_path)

    assert {:ok,
            %Concept{
              subject: ^section_matter,
              name: ^section_name,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{},
              title: ^section_title,
              prologue: []
            } = concept} =
             Concept.create(section_matter, [], assigns: [abstract: abstract])

    assert is_just_now(concept.created_at)

    assert concept.path == expected_path

    assert concept.content ==
             """
             # Introduction

             ## Description

             #{abstract}


             # Context knowledge

             #{Concept.Template.context_knowledge_hint()}




             # Artefacts

             ## Article

             - Prompt: [[Prompt for Some User Guide - Introduction (article section)]]
             - Final version: [[Some User Guide - Introduction (article section)]]

             ### Article prompt task

             Your task is to write the section "Introduction" of "Some User Guide".
             """

    assert Concept.load(concept.path) == {:ok, concept}

    assert Vault.document_path(concept.name) == concept.path
  end
end

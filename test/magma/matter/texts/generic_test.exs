defmodule Magma.Matter.Texts.GenericTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Matter.Texts.Generic

  alias Magma.Matter.Texts.Generic
  alias Magma.{Concept, Matter}

  @tag vault_files: ["concepts/Project.md"]
  test "Concept creation" do
    title = "Some Text"
    expected_path = Vault.path("concepts/texts/#{title}/#{title}.md")

    refute File.exists?(expected_path)

    assert {:ok,
            %Concept{
              subject: %Matter.Text{
                type: Generic,
                name: ^title
              },
              name: ^title,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{},
              title: ^title,
              prologue: []
            } = concept} =
             title
             |> Generic.new()
             |> Concept.create()

    assert is_just_now(concept.created_at)

    assert concept.path == expected_path

    assert concept.content ==
             """
             # #{concept.title}

             ## Description

             <!--
             What should "#{title}" cover?
             -->


             # Context knowledge

             #{Concept.Template.context_knowledge_hint()}


             # Sections

             <!--
             Don't remove or edit this section! The results of the generated table of contents will be copied to this place.
             -->


             # Artefact previews

             - [[Some Text (article) Preview]]


             # Artefacts

             ## TableOfContents

             - Prompt: [[Prompt for Some Text ToC]]
             - Final version: [[Some Text ToC]]

             ### TableOfContents prompt task

             Your task is to write an outline of "#{title}".

             Please provide the outline in the following format:

             ```markdown
             ## Title of the first section

             Abstract: Abstract of the introduction.

             ## Title of the next section

             Abstract: Abstract of the next section.

             ## Title of the another section

             Abstract: Abstract of the another section.
             ```

             <!--
             Please don't change the general structure of this outline format. The section generator relies on an outline with sections.
             -->
             """

    assert Concept.load(concept.path) == {:ok, concept}

    assert Vault.document_path(concept.name) == concept.path

    assert Concept.load(concept.path) == {:ok, concept}
  end
end

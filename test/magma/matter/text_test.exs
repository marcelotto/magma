defmodule Magma.Matter.TextTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Matter.Text

  alias Magma.{Concept, Matter}
  alias Magma.Matter.Texts.{Generic, UserGuide}

  @tag vault_files: ["concepts/Project.md"]
  test "Concept creation with Generic text type" do
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
             |> Matter.Text.new!()
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

             ``` markdown
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

  @tag vault_files: ["concepts/Project.md"]
  test "Concept creation with UserGuide text type" do
    title = "Some User Guide"
    expected_path = Vault.path("concepts/texts/#{title}/#{title}.md")

    refute File.exists?(expected_path)

    assert {:ok,
            %Concept{
              subject: %Matter.Text{
                type: UserGuide,
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
             |> Matter.Text.new!(type: UserGuide)
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

             - [[Some User Guide (article) Preview]]


             # Artefacts

             ## TableOfContents

             - Prompt: [[Prompt for Some User Guide ToC]]
             - Final version: [[Some User Guide ToC]]

             ### TableOfContents prompt task

             Your task is to write an outline of "#{title}".

             Please provide the outline in the following format:

             ``` markdown
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
  end

  @tag vault_files: "concepts/texts/Some User Guide/Some User Guide.md"
  test "Concept loading", %{vault_files: vault_file} do
    document_path = Vault.path(vault_file)

    assert {
             :ok,
             %Magma.Concept{
               subject: %Matter.Text{
                 type: UserGuide,
                 name: "Some User Guide"
               },
               path: ^document_path,
               name: "Some User Guide",
               content: content,
               custom_metadata: %{},
               aliases: [],
               tags: [],
               created_at: ~N[2023-09-13 02:41:42],
               title: "Some User Guide",
               prologue: []
             } = concept
           } =
             "Some User Guide"
             |> Matter.Text.new!(type: UserGuide)
             |> Concept.new!()
             |> Concept.load()

    assert document_path
           |> File.read!()
           |> String.trim()
           |> String.ends_with?(String.trim(content))

    assert Concept.load(document_path) == {:ok, concept}
  end
end

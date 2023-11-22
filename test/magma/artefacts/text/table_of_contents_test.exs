defmodule Magma.Artefacts.TableOfContentsTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.TableOfContents

  alias Magma.Artefacts.TableOfContents
  alias Magma.{Artefact, Concept, Generation, Prompt, PromptResult}

  import Magma.View

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide.md",
         "concepts/Project.md"
       ]
  test "Artefact.Prompt creation and loading" do
    text_concept = Concept.load!("Some User Guide")
    toc_artefact = TableOfContents.new!(text_concept)

    assert {:ok,
            %Artefact.Prompt{
              artefact: ^toc_artefact,
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} =
             Artefact.Prompt.create(toc_artefact)

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Prompt for Some User Guide ToC"

    assert prompt.path ==
             Vault.path("artefacts/generated/texts/Some User Guide/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             #{Magma.Config.System.persona_transclusion()}

             Your task is to help write a user guide called "Some User Guide".

             The user guide should be written in English in the Markdown format.

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #### Description of the Some project ![[Project#Description|]]



             ![[Some User Guide#Context knowledge|]]


             ## Request

             ![[Some User Guide#TableOfContents prompt task|]]

             ### Description of the content to be covered by 'Some User Guide' ![[Some User Guide#Description|]]
             """

    assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
  end

  @tag vault_files: [
         "artefacts/generated/texts/Some User Guide/Prompt for Some User Guide ToC.md",
         "concepts/texts/Some User Guide/Some User Guide.md"
       ]
  test "PromptResult creation and loading" do
    prompt = Artefact.Prompt.load!("Prompt for Some User Guide ToC")

    assert {:ok,
            %PromptResult{
              prompt: ^prompt,
              generation: %Generation.Mock{},
              name: "Generated Some User Guide ToC (" <> _,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt_result} = PromptResult.create(prompt)

    assert is_just_now(prompt_result.created_at)

    assert prompt_result.name ==
             "Generated Some User Guide ToC (#{NaiveDateTime.to_iso8601(prompt_result.created_at)})"

    assert prompt_result.path ==
             Vault.path(
               "artefacts/generated/texts/Some User Guide/__prompt_results__/#{prompt_result.name}.md"
             )

    assert prompt_result.content ==
             """

             #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
             #{delete_current_file_button()}

             Final version: [[Some User Guide ToC]]

             >[!attention]
             >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

             # Generated Some User Guide ToC

             foo
             """

    assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
  end

  @tag vault_files: [
         "artefacts/generated/texts/Some User Guide/__prompt_results__/Generated Some User Guide ToC (2023-09-18T12:56:00).md",
         "artefacts/generated/texts/Some User Guide/Prompt for Some User Guide ToC.md",
         "concepts/texts/Some User Guide/Some User Guide.md"
       ]
  test "Artefact.Version creation and loading" do
    concept = Concept.load!("Some User Guide")
    toc_artefact = TableOfContents.new!(concept)
    prompt_result = PromptResult.load!("Generated Some User Guide ToC (2023-09-18T12:56:00)")

    assert {:ok,
            %Artefact.Version{
              artefact: ^toc_artefact,
              draft: ^prompt_result,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = version} = Artefact.Version.create(prompt_result)

    assert is_just_now(version.created_at)

    assert version.name == "Some User Guide ToC"

    assert version.path ==
             Vault.path("artefacts/final/texts/Some User Guide/#{version.name}.md")

    assert version.content ==
             """

             #{button("Assemble sections", "magma.text.assemble", color: "blue")}

             # #{version.name}

             ## Introduction

             Abstract: Abstract of the introduction.

             ## Next section

             Abstract: Abstract of the next section.

             ## Another section

             Abstract: Abstract of the another section.
             """

    assert Artefact.Version.load(version.path) == {:ok, version}
  end
end

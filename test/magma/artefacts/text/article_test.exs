defmodule Magma.Artefacts.ArticleTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.Article

  alias Magma.Artefacts.Article
  alias Magma.{Artefact, Concept, Generation, Prompt, PromptResult}
  alias Magma.Text.Preview

  import Magma.View

  import ExUnit.CaptureLog

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
         "concepts/texts/Some User Guide/Some User Guide.md",
         "concepts/Project.md"
       ]
  test "Artefact.Prompt creation and loading" do
    section_concept = "Introduction" |> user_guide_section_concept() |> Concept.load!()

    assert {:ok,
            %Artefact.Prompt{
              artefact: Article,
              concept: ^section_concept,
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} = Article.create_prompt(section_concept)

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Prompt for Some User Guide - Introduction (article section)"

    assert prompt.path ==
             Vault.path("artefacts/generated/texts/Some User Guide/article/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             You are MagmaGPT, an assistant who helps the developers of the "Some" project during documentation and development. Your responses are in plain and clear English, so even non-native speakers can easily understand you.

             Your task is to help write a user guide called "Some User Guide".

             The user guide should be written in English in the Markdown format.

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #### Description of the Some project ![[Project#Description|]]

             #### Outline of the 'Some User Guide' content ![[Some User Guide ToC#Some User Guide ToC|]]

             #### Some background knowledge

             Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod

             #### Transcluded background knowledge ![[Document#Title|]]

             #### Section-specific background knowledge ![[DocumentWithMultipleMainSections#Section|]]


             ## Request

             ![[Some User Guide - Introduction#Article prompt task|]]

             ### Description of the intended content of the 'Introduction' section ![[Some User Guide - Introduction#Description|]]
             """

    assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
  end

  @tag vault_files: [
         "artefacts/generated/texts/Some User Guide/article/Prompt for Some User Guide - Introduction (article section).md",
         "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
         "concepts/texts/Some User Guide/Some User Guide.md"
       ]
  test "PromptResult creation and loading" do
    prompt = Artefact.Prompt.load!("Prompt for Some User Guide - Introduction (article section)")

    assert {:ok,
            %PromptResult{
              prompt: ^prompt,
              generation: %Generation.Mock{},
              name: "Generated Some User Guide - Introduction (article section) (" <> _,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt_result} = PromptResult.create(prompt)

    assert is_just_now(prompt_result.created_at)

    assert prompt_result.name ==
             "Generated Some User Guide - Introduction (article section) (#{NaiveDateTime.to_iso8601(prompt_result.created_at)})"

    assert prompt_result.path ==
             Vault.path(
               "artefacts/generated/texts/Some User Guide/article/__prompt_results__/#{prompt_result.name}.md"
             )

    assert prompt_result.content ==
             """

             #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
             #{delete_current_file_button()}

             Final version: [[Some User Guide - Introduction (article section)]]

             >[!attention]
             >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

             # Generated Some User Guide - Introduction (article section)

             foo
             """

    assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
  end

  @tag vault_files: [
         "artefacts/generated/texts/Some User Guide/article/__prompt_results__/Generated Some User Guide - Introduction (article section) (2023-09-23T00:08:00).md",
         "artefacts/generated/texts/Some User Guide/article/Prompt for Some User Guide - Introduction (article section).md",
         "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
         "concepts/texts/Some User Guide/Some User Guide.md"
       ]
  test "Artefact.Version creation and loading (section)" do
    concept = Concept.load!("Some User Guide - Introduction")

    prompt_result =
      PromptResult.load!(
        "Generated Some User Guide - Introduction (article section) (2023-09-23T00:08:00)"
      )

    assert {:ok,
            %Artefact.Version{
              artefact: Article,
              concept: ^concept,
              draft: ^prompt_result,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = version} = Artefact.Version.create(prompt_result)

    assert version.name == "Some User Guide - Introduction (article section)"

    assert version.path ==
             Vault.path("artefacts/final/texts/Some User Guide/article/#{version.name}.md")

    assert is_just_now(version.created_at)

    assert version.content ==
             """
             # #{version.name}

             The content of the generated introduction section.
             """

    assert Artefact.Version.load(version.path) == {:ok, version}
  end

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide.md",
         "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Next section (article section).md",
         "concepts/Project.md"
       ]
  test "Text.Preview creation and loading" do
    "Some User Guide ToC"
    |> Artefact.Version.load!()
    |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

    concept = Concept.load!("Some User Guide")

    assert {:ok,
            %Preview{
              artefact: Article,
              concept: ^concept,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = preview} = Preview.create(concept, Article)

    assert is_just_now(preview.created_at)

    assert preview.name == "Some User Guide (article) Preview"

    assert preview.path ==
             Vault.path(
               "artefacts/generated/texts/Some User Guide/__previews__/#{preview.name}.md"
             )

    assert preview.content ==
             """
             #{Preview.prologue()}

             # #{preview.name}

             ## Introduction ![[Some User Guide - Introduction (article section)#Some User Guide - Introduction (article section)|]]

             ## Next section ![[Some User Guide - Next section (article section)#Some User Guide - Next section (article section)|]]

             ## Another section ![[Some User Guide - Another section (article section)#Some User Guide - Another section (article section)|]]
             """

    assert Preview.load(preview.path) == {:ok, preview}
  end

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide.md",
         "artefacts/generated/texts/Some User Guide/__previews__/Some User Guide (article) Preview.md",
         "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Next section (article section).md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Another section (article section).md",
         "concepts/Project.md"
       ]
  test "Artefact.Version creation and loading (assembled article from Preview)" do
    "Some User Guide ToC"
    |> Artefact.Version.load!()
    |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

    preview = Preview.load!("Some User Guide (article) Preview")
    concept = Concept.load!("Some User Guide")

    assert {:ok,
            %Artefact.Version{
              artefact: Article,
              concept: ^concept,
              draft: ^preview,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = version} = Artefact.Version.create(preview)

    assert version.name == "Some User Guide (article)"

    assert version.path ==
             Vault.path("artefacts/final/texts/Some User Guide/#{version.name}.md")

    assert version.content ==
             """
             # Some User Guide (article) Preview

             ## Introduction

             The content of the final introduction section.

             ## Next section

             The content of the final next section.

             ## Another section

             The content of another final section.
             """

    assert is_just_now(version.created_at)

    assert Artefact.Version.load(version.path) == {:ok, version}
  end

  @tag vault_files: [
         "concepts/texts/Some User Guide/Some User Guide.md",
         "artefacts/generated/texts/Some User Guide/__previews__/Some User Guide (article) Preview.md",
         "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
         "artefacts/final/texts/Some User Guide/article/Some User Guide - Another section (article section).md",
         "concepts/Project.md"
       ]
  test "Artefact.Version creation and loading (assembled article from Preview when section artefact versions are missing)" do
    "Some User Guide ToC"
    |> Artefact.Version.load!()
    |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

    preview = Preview.load!("Some User Guide (article) Preview")

    assert capture_log(fn ->
             assert {:ok, _} = Artefact.Version.create(preview)
           end) =~
             "failed to load [[Some User Guide - Next section (article section)]] during resolution"

    version = Artefact.Version.load!("Some User Guide (article)")

    assert version.content ==
             """
             # Some User Guide (article) Preview

             ## Introduction

             The content of the final introduction section.

             ## Next section ![[Some User Guide - Next section (article section)#Some User Guide - Next section (article section)|]]

             ## Another section

             The content of another final section.
             """
  end
end

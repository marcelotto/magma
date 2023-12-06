defmodule Magma.Artefacts.ReadmeTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.Readme

  alias Magma.Artefacts.Readme
  alias Magma.{Artefact, Concept, Generation, Prompt, PromptResult}

  import Magma.View

  @tag vault_files: ["concepts/Project.md"]
  test "Artefact.Prompt creation and loading" do
    project_concept = Concept.load!("Project")
    readme_artefact = Readme.new!(project_concept)

    assert {:ok,
            %Artefact.Prompt{
              artefact: ^readme_artefact,
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} =
             Artefact.Prompt.create(readme_artefact)

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Prompt for README"

    assert prompt.path ==
             Vault.path("artefacts/generated/project/README/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             #{Magma.Config.System.persona_transclusion()}

             ![[Readme.artefact.config#System prompt|]]

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #{Magma.Config.System.context_knowledge_transclusion()}

             ![[Project.matter.config#Context knowledge|]]

             ![[Readme.artefact.config#Context knowledge|]]

             ![[Project#Context knowledge|]]


             ## Request

             ![[Project#Readme prompt task|]]

             ### Description of the 'Some' project ![[Project#Description|]]
             """

    assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
  end

  @tag vault_files: [
         "artefacts/generated/project/README/Prompt for README.md",
         "concepts/Project.md"
       ]
  test "PromptResult creation and loading (with prompt-specified generation)" do
    prompt = Artefact.Prompt.load!("Prompt for README")

    assert {:ok,
            %PromptResult{
              prompt: ^prompt,
              generation: %Generation.Mock{},
              name: "Generated README (" <> _,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt_result} = PromptResult.create(prompt)

    assert is_just_now(prompt_result.created_at)

    assert prompt_result.name ==
             "Generated README (#{NaiveDateTime.to_iso8601(prompt_result.created_at)})"

    assert prompt_result.path ==
             Vault.path(
               "artefacts/generated/project/README/__prompt_results__/#{prompt_result.name}.md"
             )

    assert prompt_result.content ==
             """

             #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
             #{delete_current_file_button()}

             Final version: [[README]]

             >[!attention]
             >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

             # Generated README

             foo
             """

    assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
  end

  @tag vault_files: [
         "artefacts/generated/project/README/__prompt_results__/Generated README (2023-10-23T22:59:00).md",
         "artefacts/generated/project/README/Prompt for README.md",
         "concepts/Project.md"
       ]
  @tag :tmp_dir
  test "Artefact.Version creation", %{tmp_dir: tmp_dir} do
    prompt_result = PromptResult.load!("Generated README (2023-10-23T22:59:00)")

    readme_path = Path.join(tmp_dir, "README.md")

    refute File.exists?(readme_path)

    assert {:ok, version_path} =
             Artefact.Version.create(prompt_result, [], readme_path: readme_path)

    assert File.exists?(readme_path)

    content = File.read!(readme_path)

    assert content ==
             """
             # Some

             An awesome README for an awesome project.
             """

    assert %File.Stat{type: :symlink} = File.lstat!(version_path)

    assert version_path == Vault.path("artefacts/final/project/README/README.md")

    assert File.read!(version_path) == content

    # check the file is indexed
    assert Vault.document_path("README") == version_path
  end
end

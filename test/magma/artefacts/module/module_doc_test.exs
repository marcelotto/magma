defmodule Magma.Artefacts.ModuleDocTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefacts.ModuleDoc

  alias Magma.Artefacts.ModuleDoc
  alias Magma.{Artefact, Concept, Generation, Prompt, PromptResult}

  import Magma.View

  test "version_path/1" do
    assert ModuleDoc.version_path(TopLevelExample) ==
             abs_path(
               "test/data/example_vault/artefacts/final/modules/TopLevelExample/ModuleDoc of TopLevelExample.md"
             )

    assert ModuleDoc.version_path(Nested.Example) ==
             abs_path(
               "test/data/example_vault/artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md"
             )
  end

  describe "get/1" do
    @tag vault_files: [
           "artefacts/final/modules/Nested/Example/ModuleDoc of Nested.Example.md",
           "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
           "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
           "concepts/modules/Nested/Nested.Example.md",
           "artefacts/final/modules/TopLevelExample/ModuleDoc of TopLevelExample.md",
           "artefacts/generated/modules/TopLevelExample/__prompt_results__/Generated ModuleDoc of TopLevelExample (2023-09-07T21:17:00).md",
           "artefacts/generated/modules/TopLevelExample/Prompt for ModuleDoc of TopLevelExample.md",
           "concepts/modules/TopLevelExample.md"
         ]
    test "when an artefact version exists" do
      assert ModuleDoc.get(Nested.Example) ==
               "The final documentation of `Nested.Example`."

      assert ModuleDoc.get(TopLevelExample) ==
               "A test module."
    end

    test "when an artefact version it does not exists" do
      refute ModuleDoc.get(NotExisting)
    end
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/modules/Nested/Example/Nested.Example.Sub.md",
         "concepts/Project.md",
         "plain/Document.md"
       ]
  test "Artefact.Prompt creation and loading" do
    module_concept = Concept.load!("Nested.Example")
    module_doc_artefact = ModuleDoc.new!(module_concept)

    assert {:ok,
            %Artefact.Prompt{
              artefact: ^module_doc_artefact,
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} =
             Artefact.Prompt.create(module_doc_artefact)

    assert is_just_now(prompt.created_at)

    assert prompt.name == "Prompt for ModuleDoc of Nested.Example"

    assert prompt.path ==
             Vault.path("artefacts/generated/modules/Nested/Example/#{prompt.name}.md")

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             #{Magma.Config.System.persona_transclusion()}

             ![[ModuleDoc.config#System prompt|]]

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #### Description of the Some project ![[Project#Description|]]

             #### Peripherally relevant modules

             ##### `Nested` ![[Nested#Description|]]

             ##### `Nested.Example.Sub` ![[Nested.Example.Sub#Description|]]

             ![[Nested.Example#Context knowledge|]]


             ## Request

             ![[Nested.Example#ModuleDoc prompt task|]]

             ### Description of the module `Nested.Example` ![[Nested.Example#Description|]]

             ### Module code

             This is the code of the module to be documented. Ignore commented out code.

             ```elixir
             defmodule Nested.Example do
               use Magma

               def foo, do: :bar
             end

             ```
             """

    assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
  end

  @tag vault_files: [
         "concepts/modules/Some/Some.DocumentWithoutSpecialSections.md",
         "concepts/Project.md"
       ]
  test "Artefact.Prompt creation and loading when special sections are missing in concept" do
    module_concept = Concept.load!("Some.DocumentWithoutSpecialSections")
    module_doc_artefact = ModuleDoc.new!(module_concept)

    assert {:ok,
            %Artefact.Prompt{
              artefact: ^module_doc_artefact,
              generation: %Generation.Mock{},
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt} =
             Artefact.Prompt.create(module_doc_artefact)

    assert prompt.name == "Prompt for ModuleDoc of Some.DocumentWithoutSpecialSections"

    assert prompt.path ==
             Vault.path(
               "artefacts/generated/modules/Some/DocumentWithoutSpecialSections/#{prompt.name}.md"
             )

    assert prompt.content ==
             """
             #{Prompt.Template.controls(prompt)}

             # #{prompt.name}

             ## System prompt

             #{Magma.Config.System.persona_transclusion()}

             ![[ModuleDoc.config#System prompt|]]

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

             #### Description of the Some project ![[Project#Description|]]

             #### Peripherally relevant modules

             ##### `Some` ![[Some#Description|]]

             ![[Some.DocumentWithoutSpecialSections#Context knowledge|]]


             ## Request

             ![[Some.DocumentWithoutSpecialSections#ModuleDoc prompt task|]]

             ### Description of the module `Some.DocumentWithoutSpecialSections` ![[Some.DocumentWithoutSpecialSections#Description|]]

             ### Module code

             This is the code of the module to be documented. Ignore commented out code.

             ```elixir

             ```
             """
  end

  @tag vault_files: [
         "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
         "concepts/modules/Nested/Nested.Example.md"
       ]
  test "PromptResult creation and loading (with prompt-specified generation)" do
    prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

    assert {:ok,
            %PromptResult{
              prompt: ^prompt,
              generation: %Generation.Mock{},
              name: "Generated ModuleDoc of Nested.Example (" <> _,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = prompt_result} = PromptResult.create(prompt)

    assert is_just_now(prompt_result.created_at)

    assert prompt_result.name ==
             "Generated ModuleDoc of Nested.Example (#{NaiveDateTime.to_iso8601(prompt_result.created_at)})"

    assert prompt_result.path ==
             Vault.path(
               "artefacts/generated/modules/Nested/Example/__prompt_results__/#{prompt_result.name}.md"
             )

    assert prompt_result.content ==
             """

             #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
             #{delete_current_file_button()}

             Final version: [[ModuleDoc of Nested.Example]]

             >[!attention]
             >This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.

             # Generated ModuleDoc of Nested.Example

             foo
             """

    assert PromptResult.load(prompt_result.path) == {:ok, prompt_result}
  end

  @tag vault_files: [
         "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
         "concepts/modules/Nested/Nested.Example.md"
       ]
  test "PromptResult creation and loading (with explicit generation)" do
    prompt = Artefact.Prompt.load!("Prompt for ModuleDoc of Nested.Example")

    generation =
      Generation.Mock.new!(
        expected_system_prompt: "You are an assistent for writing Elixir moduledocs.\n",
        expected_prompt: "Generate a moduledoc for `Nested.Example`.\n",
        result: "bar"
      )

    assert {:ok,
            %PromptResult{
              prompt: ^prompt,
              generation: ^generation,
              name: "Generated ModuleDoc of Nested.Example (" <> _,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            }} = PromptResult.create(prompt, generation: generation)
  end

  @tag vault_files: [
         "artefacts/generated/modules/Nested/Example/__prompt_results__/Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00).md",
         "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
         "concepts/modules/Nested/Nested.Example.md"
       ]
  test "Artefact.Version creation and loading" do
    concept = Concept.load!("Nested.Example")
    module_doc_artefact = ModuleDoc.new!(concept)

    prompt_result =
      PromptResult.load!("Generated ModuleDoc of Nested.Example (2023-08-23T12:53:00)")

    assert {:ok,
            %Artefact.Version{
              artefact: ^module_doc_artefact,
              draft: ^prompt_result,
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = version} = Artefact.Version.create(prompt_result)

    assert is_just_now(version.created_at)

    assert version.name == "ModuleDoc of Nested.Example"

    assert version.path ==
             Vault.path("artefacts/final/modules/Nested/Example/#{version.name}.md")

    assert version.content ==
             """

             >[!caution]
             >Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
             >
             >Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

             # #{version.name}

             ## #{ModuleDoc.prompt_result_section_title()}

             The final documentation of `Nested.Example`.
             """

    assert Artefact.Version.load(version.path) == {:ok, version}
  end
end

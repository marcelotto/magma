defmodule Magma.Artefact.PromptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.Prompt

  alias Magma.{Artefacts, Artefact, Concept, Generation, Prompt}

  describe "new/1" do
    test "ModuleDoc artefact" do
      concept = module_concept()

      assert {:ok,
              %Artefact.Prompt{
                artefact: Artefacts.ModuleDoc,
                concept: ^concept,
                tags: nil,
                aliases: nil,
                created_at: nil,
                content: nil
              } = prompt} = Artefact.Prompt.new(concept, Artefacts.ModuleDoc)

      assert prompt.name == "Prompt for ModuleDoc of Nested.Example"

      assert prompt.path ==
               Vault.path("artefacts/generated/modules/Nested/Example/#{prompt.name}.md")

      assert Artefacts.ModuleDoc.prompt!(concept) == prompt
    end

    test "TableOfContents artefact" do
      concept = user_guide_concept()

      assert {:ok,
              %Artefact.Prompt{
                artefact: Artefacts.TableOfContents,
                concept: ^concept,
                generation: nil,
                tags: nil,
                aliases: nil,
                created_at: nil,
                content: nil
              } = prompt} = Artefact.Prompt.new(concept, Artefacts.TableOfContents)

      assert prompt.name == "Prompt for Some User Guide ToC"

      assert prompt.path ==
               Vault.path("artefacts/generated/texts/Some User Guide/#{prompt.name}.md")

      assert Artefacts.TableOfContents.prompt!(concept) == prompt
    end
  end

  describe "create/1 (and re-load/1)" do
    @tag vault_files: [
           "concepts/modules/Nested/Nested.Example.md",
           "concepts/modules/Nested/Example/Nested.Example.Sub.md",
           "concepts/Project.md",
           "plain/Document.md"
         ]
    test "ModuleDoc artefact" do
      module_concept = Nested.Example |> module_concept() |> Concept.load!()

      assert {:ok,
              %Artefact.Prompt{
                artefact: Artefacts.ModuleDoc,
                concept: ^module_concept,
                generation: %Generation.Mock{},
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt} = Artefacts.ModuleDoc.create_prompt(module_concept)

      assert is_just_now(prompt.created_at)

      assert prompt.name == "Prompt for ModuleDoc of Nested.Example"

      assert prompt.content ==
               """
               #{Prompt.Template.controls(prompt)}

               # #{prompt.name}

               ## System prompt

               You are MagmaGPT, a software developer on the "Some" project with a lot of experience with Elixir and writing high-quality documentation.

               Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

               ```markdown
               ## Moduledoc

               The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

               Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


               ## Function docs

               In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

               ### `function/1`

               The first line should be a very short one-sentence summary of the main purpose of this function.

               Then follows the main body of the function documentation.
               ```

               <!--
               You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
               -->

               ### Context knowledge

               The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

               #### Description of the Some project ![[Project#Description|]]

               #### Peripherally relevant modules

               ##### `Nested` ![[Nested#Description|]]

               ##### `Nested.Example.Sub` ![[Nested.Example.Sub#Description|]]

               #### Some background knowledge

               Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod

               #### Transcluded background knowledge ![[Document#Title|]]


               ## Request

               ### ![[Nested.Example#ModuleDoc prompt task|]]

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
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/Project.md"
         ]
    test "TableOfContents artefact" do
      text_concept = "Some User Guide" |> user_guide_concept() |> Concept.load!()

      assert {:ok,
              %Artefact.Prompt{
                artefact: Artefacts.TableOfContents,
                concept: ^text_concept,
                generation: %Generation.Mock{},
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt} = Artefacts.TableOfContents.create_prompt(text_concept)

      assert is_just_now(prompt.created_at)

      assert prompt.name == "Prompt for Some User Guide ToC"

      assert prompt.content ==
               """
               #{Prompt.Template.controls(prompt)}

               # #{prompt.name}

               ## System prompt

               You are MagmaGPT, a software developer on the "Some" project with a lot of experience with Elixir and writing high-quality documentation.

               Your task is to help write a user guide called "Some User Guide".

               The user guide should be written in English in the Markdown format.

               ### Context knowledge

               The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

               #### Description of the Some project ![[Project#Description|]]



               #### Some background knowledge

               Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod

               #### Transcluded background knowledge ![[Document#Title|]]


               ## Request

               ### ![[Some User Guide#TableOfContents prompt task|]]

               ### Description of the content to be covered by the 'Some User Guide' User guide ![[Some User Guide#Description|]]
               """

      assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
    end

    @tag vault_files: [
           "concepts/texts/Some User Guide/Some User Guide - Introduction.md",
           "concepts/texts/Some User Guide/Some User Guide.md",
           "concepts/Project.md"
         ]
    test "Section artefact" do
      section_concept = "Introduction" |> user_guide_section_concept() |> Concept.load!()

      assert {:ok,
              %Artefact.Prompt{
                artefact: Artefacts.Article,
                concept: ^section_concept,
                generation: %Generation.Mock{},
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt} = Artefacts.Article.create_prompt(section_concept)

      assert is_just_now(prompt.created_at)

      assert prompt.name == "Prompt for Some User Guide - Introduction (article section)"

      assert prompt.path ==
               Vault.path("artefacts/generated/texts/Some User Guide/article/#{prompt.name}.md")

      assert prompt.content ==
               """
               #{Prompt.Template.controls(prompt)}

               # #{prompt.name}

               ## System prompt

               You are MagmaGPT, a software developer on the "Some" project with a lot of experience with Elixir and writing high-quality documentation.

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

               ### ![[Some User Guide - Introduction#Article prompt task|]]

               ### Description of the intended content of the 'Introduction' section ![[Some User Guide - Introduction#Description|]]
               """

      assert Artefact.Prompt.load(prompt.path) == {:ok, prompt}
    end
  end
end

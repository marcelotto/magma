defmodule Magma.Text.PreviewTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Text.Preview

  alias Magma.Text.Preview
  alias Magma.{Concept, Artefact, Artefacts}

  describe "create/1 (and re-load/1)" do
    @tag vault_files: [
           "concepts/texts/Some User Guide/Some User Guide.md",
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Introduction (article section).md",
           "artefacts/final/texts/Some User Guide/article/Some User Guide - Next section (article section).md",
           "concepts/Project.md"
         ]
    test "Article artefact" do
      "Some User Guide ToC"
      |> Artefact.Version.load!()
      |> Magma.Text.Assembler.assemble(force: true, artefacts: false)

      concept = Concept.load!("Some User Guide")

      assert {:ok,
              %Preview{
                concept: ^concept,
                artefact: Artefacts.Article,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = preview} = Preview.create(concept, Artefacts.Article)

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
  end
end

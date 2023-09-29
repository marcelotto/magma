defmodule Magma.Obsidian.View.HelperTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Obsidian.View.Helper

  alias Magma.Obsidian.View.Helper

  alias Magma.{Concept, Document}
  alias Magma.DocumentStruct.Section

  describe "include/3" do
    test "with section" do
      section_content =
        """
        # Foo

        <!--
        Some comment
        -->

        ## Bar

        baz
        """

      section = section(section_content)

      assert Helper.include(section) == String.trim(section_content)

      assert Helper.include(section, "Bar") ==
               """
               ## Bar

               baz
               """
               |> String.trim()

      assert Helper.include(section, ["Bar"]) ==
               """
               ## Bar

               baz
               """
               |> String.trim()

      assert Helper.include(section, nil, header: false) ==
               """
               <!--
               Some comment
               -->

               ## Bar

               baz
               """
               |> String.trim()

      assert Helper.include(section, nil, level: 3) ==
               """
               ### Foo

               <!--
               Some comment
               -->

               #### Bar

               baz
               """
               |> String.trim()

      assert Helper.include(section, nil, remove_comments: true) ==
               """
               # Foo

               ## Bar

               baz
               """
               |> String.trim()

      assert Helper.include(section, nil, header: false, level: 2, remove_comments: true) ==
               """
               ### Bar

               baz
               """
               |> String.trim()
    end

    @tag vault_files: ["concepts/modules/Nested/Nested.Example.md"]
    test "with concept" do
      concept = Concept.load!("Nested.Example")

      description =
        """
        ## Description

        This is an example description of the module:

        Module `Nested.Example` does:

        -   x
        -   y
        """
        |> String.trim()

      assert Helper.include(concept) == description

      assert Helper.include(concept, :title) ==
               """
               # `Nested.Example`

               #{description}
               """
               |> String.trim()

      assert Helper.include(concept, "Description") == description

      assert Helper.include(concept, "Context knowledge") ==
               concept
               |> Concept.context_knowledge_section()
               |> Section.to_string()
               |> String.trim()

      assert Helper.include(concept, "Some background knowledge") ==
               """
               ## Some background knowledge

               Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod
               """
               |> String.trim()

      assert Helper.include(concept, "Some background knowledge", header: false) ==
               "Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod"

      assert Helper.include(concept, nil, level: 1) ==
               """
               # Description

               This is an example description of the module:

               Module `Nested.Example` does:

               -   x
               -   y

               """
               |> String.trim()

      assert Helper.include(concept, "Context knowledge",
               header: false,
               level: 3,
               remove_comments: true
             ) ==
               """
               #### Some background knowledge

               Nostrud qui magna officia consequat consectetur dolore sed amet eiusmod

               #### Transcluded background knowledge ![[Document#Title|]]
               """
               |> String.trim()
    end

    @tag vault_files: [
           "artefacts/final/texts/Some User Guide/Some User Guide ToC.md",
           "concepts/texts/Some User Guide/Some User Guide.md"
         ]
    test "with document" do
      {:ok, document} = Document.Loader.load("Some User Guide ToC")

      body =
        """
        # Some User Guide ToC

        ## Introduction

        Abstract: Abstract of the introduction.

        ## Next section

        Abstract: Abstract of the next section.

        ## Another section

        Abstract: Abstract of the another section.
        """
        |> String.trim()

      assert Helper.include(document) == body

      assert Helper.include(document, :title) == body
      assert Helper.include(document, "Some User Guide ToC") == body

      assert Helper.include(document, :all) ==
               """
               ``` button
               name Assemble sections
               type command
               action Shell commands: Execute: magma.text.assemble
               color blue
               ```

               #{body}
               """
               |> String.trim()

      assert Helper.include(document, "Introduction") ==
               """
               ## Introduction

               Abstract: Abstract of the introduction.
               """
               |> String.trim()

      assert Helper.include(document, "Introduction", header: false) ==
               "Abstract: Abstract of the introduction."

      assert Helper.include(document, nil, level: 3) ==
               """
               ### Some User Guide ToC

               #### Introduction

               Abstract: Abstract of the introduction.

               #### Next section

               Abstract: Abstract of the next section.

               #### Another section

               Abstract: Abstract of the another section.
               """
               |> String.trim()

      assert Helper.include(document, "Some User Guide ToC",
               header: false,
               level: 2,
               remove_comments: true
             ) ==
               """
               ### Introduction

               Abstract: Abstract of the introduction.

               ### Next section

               Abstract: Abstract of the next section.

               ### Another section

               Abstract: Abstract of the another section.
               """
               |> String.trim()
    end
  end
end

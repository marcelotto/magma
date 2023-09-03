defmodule Magma.DocumentStruct.SectionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  describe "section_by_title/1" do
    test "unnested" do
      assert %Section{title: "Example title"} =
               section(:without_subsections)
               |> Section.section_by_title("Example title")
    end

    test "nested" do
      assert %Section{title: "Subsection 1"} =
               section(:with_subsections)
               |> Section.section_by_title("Subsection 1")

      assert %Section{title: "Subsection 1.2"} =
               section(:with_subsections)
               |> Section.section_by_title("Subsection 1.2")

      assert %Section{title: "Subsection 2"} =
               section(:with_subsections)
               |> Section.section_by_title("Subsection 2")
    end

    test "when no section could be found" do
      assert section(:without_subsections)
             |> Section.section_by_title("No existing") == nil
    end
  end

  describe "to_string/2" do
    test "single section (without header)" do
      assert Section.to_string(section(:without_subsections), header: false) == "Foo\n"
    end

    test "single section (with header)" do
      assert Section.to_string(section(:without_subsections), header: true) ==
               content_without_subsections()
    end

    test "with subsections" do
      assert Section.to_string(section(:with_subsections), header: true) ==
               content_with_subsections()

      assert Section.to_string(section(:with_subsections), header: false, subsections: false) ==
               "Foo\n"
    end

    test "level option" do
      assert Section.to_string(section(:with_subsections), header: true, level: 3) ==
               """
               ### Example title

               Foo

               #### Subsection 1

               Labore enim excepteur aute veniam.

               ##### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               #### Subsection 2

               Nisi do voluptate esse culpa sint.
               """

      assert Section.to_string(section(:with_subsections), header: false, level: 1) ==
               """
               Foo

               ## Subsection 1

               Labore enim excepteur aute veniam.

               ### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               ## Subsection 2

               Nisi do voluptate esse culpa sint.
               """
    end

    @tag vault_files: "__concepts__/Project.md"
    test "resolve_transclusions option" do
      assert """
             ## Example title

             Foo:

             ![[Project#Description]]
             """
             |> section()
             |> Section.to_string(header: true, resolve_transclusions: true) ==
               """
               ## Example title

               Foo:

               ### Description

               This is the project description.
               """
    end

    @tag skip: "Pandoc resolves Obsidian transclusions to ![[Some Document|]]"
    test "Pandoc handling of Obsidian transclusions" do
      content =
        """
        ## Test

        ![[Some Document]]

        ![[Some Document#Some Section]]
        """

      assert content
             |> section()
             |> Section.to_string(header: true, resolve_transclusions: false) == content
    end
  end

  describe "shift_level/2" do
    test "zero shift" do
      assert section(:with_subsections)
             |> Section.shift_level(0)
             |> Section.to_string(header: true) ==
               content_with_subsections()
    end

    test "valid shifts" do
      assert section(:with_subsections)
             |> Section.shift_level(+1)
             |> Section.to_string(header: true) ==
               """
               ### Example title

               Foo

               #### Subsection 1

               Labore enim excepteur aute veniam.

               ##### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               #### Subsection 2

               Nisi do voluptate esse culpa sint.
               """

      assert section(:with_subsections)
             |> Section.shift_level(+3)
             |> Section.to_string(header: true) ==
               """
               ##### Example title

               Foo

               ###### Subsection 1

               Labore enim excepteur aute veniam.

               ####### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               ###### Subsection 2

               Nisi do voluptate esse culpa sint.
               """

      assert section(:with_subsections)
             |> Section.shift_level(-1)
             |> Section.to_string(header: true) ==
               """
               # Example title

               Foo

               ## Subsection 1

               Labore enim excepteur aute veniam.

               ### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               ## Subsection 2

               Nisi do voluptate esse culpa sint.
               """
    end

    test "out of bound shift" do
      assert_raise RuntimeError, fn ->
        Section.shift_level(section(:with_subsections), -2)
      end
    end
  end

  describe "set_level/2" do
    test "when already at the given level" do
      assert section(:with_subsections)
             |> Section.set_level(2)
             |> Section.to_string(header: true) ==
               content_with_subsections()
    end

    test "shifting" do
      assert section(:with_subsections)
             |> Section.set_level(3)
             |> Section.to_string(header: true) ==
               """
               ### Example title

               Foo

               #### Subsection 1

               Labore enim excepteur aute veniam.

               ##### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               #### Subsection 2

               Nisi do voluptate esse culpa sint.
               """

      assert section(:with_subsections)
             |> Section.set_level(1)
             |> Section.to_string(header: true) ==
               """
               # Example title

               Foo

               ## Subsection 1

               Labore enim excepteur aute veniam.

               ### Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               ## Subsection 2

               Nisi do voluptate esse culpa sint.
               """
    end

    test "with invalid level" do
      assert_raise RuntimeError, fn ->
        Section.shift_level(section(:with_subsections), -2)
      end
    end
  end

  describe "resolve_transclusions/1" do
    @describetag vault_files: [
                   "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md",
                   "__concepts__/Project.md"
                 ]

    test "document transclusion" do
      assert """
             ## Example title

             Foo:

             ![[Project]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: true, resolve_transclusions: false) ==
               """
               ## Example title

               Foo:

               ### Some Project project

               #### Description

               This is the project description.
               """

      assert """
             ## Example title

             Foo:

             ![[Some.DocumentWithFrontMatter]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false, resolve_transclusions: false) ==
               """
               Foo:

               ### `Some.DocumentWithFrontMatter`

               #### Description

               This is an example description of the module:

               Module `Some.DocumentWithFrontMatter` does:

               -   x
               -   y

               ------------------------------------------------------------------------

               #### Notes

               ##### Example note

               Here we have an example note with some text.

               ------------------------------------------------------------------------

               ### Artefact system prompts

               #### Commons

               ##### Spec

               ###### Expertise

               -   \\<%= project.expertise %\\>
               -   Some additional expertise
               """
    end

    test "section transclusion" do
      assert """
             ## Example title

             Foo:

             ![[Project#Description]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: true, resolve_transclusions: false) ==
               """
               ## Example title

               Foo:

               ### Description

               This is the project description.
               """

      assert """
             ## Example title

             Foo:

             ![[Some.DocumentWithFrontMatter#Notes]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false, resolve_transclusions: false) ==
               """
               Foo:

               ### Notes

               #### Example note

               Here we have an example note with some text.

               ------------------------------------------------------------------------
               """
    end

    test "transclusion with custom header" do
      assert """
             ## Example title

             Foo:

             ### Some subsection ![[Project]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: true, resolve_transclusions: false) ==
               """
               ## Example title

               Foo:

               ### Some subsection

               #### Description

               This is the project description.
               """

      assert """
             ## Example title

             Foo:

             ### Example section ![[Some.DocumentWithFrontMatter#Description]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false, resolve_transclusions: false) ==
               """
               Foo:

               ### Example section

               This is an example description of the module:

               Module `Some.DocumentWithFrontMatter` does:

               -   x
               -   y

               ------------------------------------------------------------------------
               """

      assert """
             ## Example title

             Foo:

             #### Example notes ![[Some.DocumentWithFrontMatter#Notes]]

             This text should appear at the end of the transcluded content.
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false, resolve_transclusions: false) ==
               """
               Foo:

               #### Example notes

               ##### Example note

               Here we have an example note with some text.

               ------------------------------------------------------------------------

               This text should appear at the end of the transcluded content.
               """
    end
  end
end

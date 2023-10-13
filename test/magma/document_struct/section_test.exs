defmodule Magma.DocumentStruct.SectionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  describe "empty?/1" do
    test "with content" do
      refute """
             # Section

             Foo
             """
             |> section()
             |> Section.empty?()
    end

    test "without content" do
      assert """
             # Section


             """
             |> section()
             |> Section.empty?()
    end

    test "with content in subsections only" do
      refute """
             # Section

             ## Subsection

             Foo
             """
             |> section()
             |> Section.empty?()
    end

    test "without content and subsection without content" do
      refute """
             # Section

             ## Subsection

             """
             |> section()
             |> Section.empty?()
    end
  end

  describe "empty_content?/1" do
    test "with content" do
      refute """
             # Section

             Foo
             """
             |> section()
             |> Section.empty_content?()
    end

    test "without content" do
      assert """
             # Section


             """
             |> section()
             |> Section.empty_content?()
    end

    test "with content in subsections only" do
      refute """
             # Section

             ## Subsection

             Foo
             """
             |> section()
             |> Section.empty_content?()
    end

    test "without content and subsection without content" do
      assert """
             # Section

             ## Subsection

             """
             |> section()
             |> Section.empty_content?()
    end
  end

  describe "section_by_title/1" do
    test "flat" do
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
      assert Section.to_string(section(:without_subsections)) ==
               content_without_subsections()
    end

    test "with subsections" do
      assert Section.to_string(section(:with_subsections)) ==
               content_with_subsections()

      assert Section.to_string(section(:with_subsections), header: false, subsections: false) ==
               "Foo\n"
    end

    test "level option" do
      assert Section.to_string(section(:with_subsections), level: 3) ==
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

      assert """
             # Example title

             ## Subsection 1

             Labore enim excepteur aute veniam.

             ### Subsection 1.2

             Lorem consequat amet minim pariatur, dolore ut.

             ## Subsection 2

             Nisi do voluptate esse culpa sint.
             """
             |> section()
             |> Section.to_string(level: 0, header: false) ==
               """
               # Subsection 1

               Labore enim excepteur aute veniam.

               ## Subsection 1.2

               Lorem consequat amet minim pariatur, dolore ut.

               # Subsection 2

               Nisi do voluptate esse culpa sint.
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
             |> Section.to_string() == content
    end
  end

  describe "shift_level/2" do
    test "zero shift" do
      assert section(:with_subsections)
             |> Section.shift_level(0)
             |> Section.to_string() ==
               content_with_subsections()
    end

    test "valid shifts" do
      assert section(:with_subsections)
             |> Section.shift_level(+1)
             |> Section.to_string() ==
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
             |> Section.to_string() ==
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
             |> Section.to_string() ==
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
        Section.shift_level(section(:with_subsections), -3)
      end
    end
  end

  describe "set_level/2" do
    test "when already at the given level" do
      assert section(:with_subsections)
             |> Section.set_level(2)
             |> Section.to_string() ==
               content_with_subsections()
    end

    test "shifting" do
      assert section(:with_subsections)
             |> Section.set_level(3)
             |> Section.to_string() ==
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
             |> Section.to_string() ==
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
        Section.set_level(section(:with_subsections), -1)
      end
    end
  end

  describe "resolve_links/1" do
    test "unstyled" do
      assert """
             # `Some.DocumentWithLinks`

             This is a section with an [[embedded internal link]].

             [[A single link paragraph]]

             ## Some special kinds of links

             - [[Link with|Alternative Title]]
             - [[Link to#Section]]
             - [[Link to#^block]]

             """
             |> section()
             |> Section.resolve_links()
             |> Section.to_string() ==
               """
               # `Some.DocumentWithLinks`

               This is a section with an embedded internal link.

               A single link paragraph

               ## Some special kinds of links

               -   Alternative Title
               -   Link to#Section
               -   Link to#\\^block
               """
    end

    test "styled" do
      assert """
             # `Some.DocumentWithLinks`

             This is a section with an [[embedded internal link]].

             [[A single link paragraph]]

             ## Some special kinds of links

             - [[Link with|Alternative Title]]
             - [[Link to#Section]]
             - [[Link to#^block]]

             """
             |> section()
             |> Section.resolve_links(style: :emph)
             |> Section.to_string() ==
               """
               # `Some.DocumentWithLinks`

               This is a section with an *embedded internal link*.

               *A single link paragraph*

               ## Some special kinds of links

               -   *Alternative Title*
               -   *Link to#Section*
               -   *Link to#\\^block*
               """
    end
  end

  test "remove_comments/1" do
    assert """
           # `Some.DocumentWithComments`

           ## Description

           This is a document with <!-- inline --> comments.

           <!--
           across

           multiple

           lines
           -->
           """
           |> section()
           |> Section.remove_comments()
           |> Section.to_string() ==
             """
             # `Some.DocumentWithComments`

             ## Description

             This is a document with comments.
             """
  end
end

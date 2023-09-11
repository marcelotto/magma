defmodule Magma.DocumentStruct.SectionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  import ExUnit.CaptureLog

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
        Section.shift_level(section(:with_subsections), -2)
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
        Section.shift_level(section(:with_subsections), -2)
      end
    end
  end

  describe "resolve_transclusions/1" do
    test "transclusion of unknown document" do
      section =
        """
        ## Example title

        ![[Nested.Example]]
        """
        |> section()

      assert capture_log(fn ->
               assert Section.resolve_transclusions(section) == section
             end) =~ "failed to load [[Nested.Example]] during resolution"

      section =
        """
        ## Example title

        ### Alt. title ![[Nested.Example]]
        """
        |> section()

      assert capture_log(fn ->
               assert Section.resolve_transclusions(section) == section
             end) =~ "failed to load [[Nested.Example]] during resolution"
    end

    @describetag vault_files: [
                   "concepts/modules/Nested/Nested.Example.md",
                   "concepts/modules/Some/Some.DocumentWithTransclusion.md",
                   "concepts/Project.md"
                 ]

    test "document transclusion" do
      assert """
             ## Example title

             Foo:

             ![[Project]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               Foo:

               ### Some Project project

               #### Description

               This is the project description.

               #### Knowledge Base
               """

      assert """
             ## Example title

             Foo:

             ![[Nested.Example]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false) ==
               """
               Foo:

               ### `Nested.Example`

               #### Description

               This is an example description of the module:

               Module `Nested.Example` does:

               -   x
               -   y

               ------------------------------------------------------------------------

               #### Notes

               ##### Example note

               Here we have an example note with some text.

               ------------------------------------------------------------------------
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
             |> Section.to_string() ==
               """
               ## Example title

               Foo:

               ### Description

               This is the project description.
               """

      assert """
             ## Example title

             Foo:

             ![[Nested.Example#Notes]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false) ==
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
             |> Section.to_string() ==
               """
               ## Example title

               Foo:

               ### Some subsection

               #### Description

               This is the project description.

               #### Knowledge Base
               """

      assert """
             ## Example title

             Foo:

             ### Example section ![[Nested.Example#Description]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false) ==
               """
               Foo:

               ### Example section

               This is an example description of the module:

               Module `Nested.Example` does:

               -   x
               -   y

               ------------------------------------------------------------------------
               """

      assert """
             ## Example title

             Foo:

             #### Example notes ![[Nested.Example#Notes]]

             This text should appear at the end of the transcluded content.
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string(header: false) ==
               """
               Foo:

               #### Example notes

               ##### Example note

               Here we have an example note with some text.

               ------------------------------------------------------------------------

               This text should appear at the end of the transcluded content.
               """
    end

    test "custom header transclusion with empty content" do
      assert """
             ## Example title

             Foo:

             ### This should be removed ![[Project#Knowledge Base]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               Foo:
               """
    end

    @tag vault_files: "plain/Document.md"
    test "plain Markdown documents" do
      assert """
             ## Example title

             ![[Document]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               #### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.
               """

      assert """
             ## Example title

             ### Alt. title ![[Document]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Alt. title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               #### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.
               """

      assert """
             ## Example title

             ![[Document#Title]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               #### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.
               """

      assert """
             ## Example title

             ### Alt. title ![[Document#Title]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Alt. title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               #### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.
               """
    end

    @tag vault_files: "plain/DocumentWithMultipleMainSections.md"
    test "plain Markdown documents with multiple top-level section" do
      assert """
             ## Example title

             ![[DocumentWithMultipleMainSections]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               ##### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.

               #### Reference

               This is another top-level section.
               """

      assert """
             ## Example title

             ### Alt. title ![[DocumentWithMultipleMainSections]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Alt. title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               ##### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.

               #### Reference

               This is another top-level section.
               """

      assert """
             ## Example title

             ![[DocumentWithMultipleMainSections#Title]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Title

               This is an ordinary Markdown document, i.e. a document without a `magma_type`.

               #### Section

               Deserunt amet velit consequat exercitation cillum nisi nisi.
               """

      assert """
             ## Example title

             ### Alt. title ![[DocumentWithMultipleMainSections#Reference]]
             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Alt. title

               This is another top-level section.
               """
    end

    test "when the same document is transcluded multiple times" do
      assert """
             ## Example title

             ![[Project#Description]]

             ![[Project#Knowledge Base]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### Description

               This is the project description.

               ### Knowledge Base
               """
    end

    test "recursive transclusion resolution" do
      assert """
             ## Example title

             ![[Some.DocumentWithTransclusion]]

             """
             |> section()
             |> Section.resolve_transclusions()
             |> Section.to_string() ==
               """
               ## Example title

               ### `Some.DocumentWithTransclusion`

               #### Description

               This is an example description of the module:

               `Nested.Example` is relevant so we include its description

               ##### Description

               This is an example description of the module:

               Module `Nested.Example` does:

               -   x
               -   y

               ------------------------------------------------------------------------

               Some final remarks.

               #### Background knowledge about the project

               ##### Description

               This is the project description.

               ##### Knowledge Base

               Again, some final remarks.

               ##### Subsection after transclusion
               """
    end

    @tag vault_files: [
           "concepts/modules/Some/Some.DocumentWithDirectCycle.md",
           "concepts/modules/Some/Some.DocumentWithDirectCycle2.md"
         ]
    test "recursive transclusion resolution with direct cycle" do
      assert_raise RuntimeError,
                   "recursive cycle during transclusion resolution of Some.DocumentWithDirectCycle#Description",
                   fn ->
                     """
                     ## Example title

                     ![[Some.DocumentWithDirectCycle]]

                     """
                     |> section()
                     |> Section.resolve_transclusions()
                   end

      assert_raise RuntimeError,
                   "recursive cycle during transclusion resolution of Some.DocumentWithDirectCycle2#Description",
                   fn ->
                     """
                     ## Example title

                     ### Cycle ![[Some.DocumentWithDirectCycle2]]

                     """
                     |> section()
                     |> Section.resolve_transclusions()
                   end
    end

    @tag vault_files: [
           "concepts/modules/Some/Some.DocumentWithIndirectCycle1.md",
           "concepts/modules/Some/Some.DocumentWithIndirectCycle2.md"
         ]
    test "recursive transclusion resolution with indirect cycle" do
      assert_raise RuntimeError,
                   "recursive cycle during transclusion resolution of Some.DocumentWithIndirectCycle1#Description",
                   fn ->
                     """
                     ## Example title

                     ![[Some.DocumentWithIndirectCycle1]]

                     """
                     |> section()
                     |> Section.resolve_transclusions()
                   end

      assert_raise RuntimeError,
                   "recursive cycle during transclusion resolution of Some.DocumentWithIndirectCycle2",
                   fn ->
                     """
                     ## Example title

                     ![[Some.DocumentWithIndirectCycle2]]

                     """
                     |> section()
                     |> Section.resolve_transclusions()
                   end
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

defmodule Magma.DocumentStruct.TransclusionResolutionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.DocumentStruct.TransclusionResolution

  alias Magma.DocumentStruct.Section

  import ExUnit.CaptureLog

  test "transclusion of unknown document" do
    section =
      """
      ## Example title

      ![[NotExisting]]
      """
      |> section()

    assert capture_log(fn ->
             assert Section.resolve_transclusions(section) == section
           end) =~ "failed to load [[NotExisting]] during resolution"

    section =
      """
      ## Example title

      ### Alt. title ![[NotExisting]]
      """
      |> section()

    assert capture_log(fn ->
             assert Section.resolve_transclusions(section) == section
           end) =~ "failed to load [[NotExisting]] during resolution"

    section =
      """
      ## Example title

      ### ![[NotExisting]]
      """
      |> section()

    assert capture_log(fn ->
             assert Section.resolve_transclusions(section) == section
           end) =~ "failed to load [[NotExisting]] during resolution"
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/Project.md"
       ]
  test "inline transclusion" do
    assert """
           ## Example title

           Foo:

           ![[Project]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Description

             This is the project description.

             ### Knowledge Base
             """

    assert """
           ## Example title

           Foo:

           ![[Nested.Example#Description|]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y
             """

    assert """
           ## Example title

           Foo:

           ![[Nested.Example#Notes]]

           This text should appear at the end of the transcluded content.
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Example note

             Here we have an example note with some text.

             ------------------------------------------------------------------------

             This text should appear at the end of the transcluded content.
             """
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/modules/Some/Some.DocumentWithTransclusion.md",
         "concepts/Project.md"
       ]
  test "multiple inline transclusions" do
    assert """
           ## Example title

           ![[Project]]

           Foo:

           ![[Some.DocumentWithTransclusion|]]

           ![[Nested.Example#Description|]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Description

             This is the project description.

             ### Knowledge Base

             Foo:

             ### Description

             This is an example description of the module:

             `Nested.Example` is relevant so we include its description

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y

             Some final remarks.

             ### Background knowledge about the project

             #### Description

             This is the project description.

             #### Knowledge Base

             Again, some final remarks.

             #### Subsection after transclusion

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y
             """
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/Project.md"
       ]
  test "custom header transclusion" do
    assert """
           ## Example title

           Foo:

           ### Some subsection ![[Project]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
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
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Example section

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y
             """

    assert """
           ## Example title

           Foo:

           #### Example notes ![[Nested.Example#Notes]]

           This text should appear at the end of the transcluded content.
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             #### Example notes

             ##### Example note

             Here we have an example note with some text.

             ------------------------------------------------------------------------

             This text should appear at the end of the transcluded content.
             """
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/Project.md"
       ]
  test "empty header transclusion" do
    assert """
           ## Example title

           Foo:

           ### ![[Project]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Some project

             #### Description

             This is the project description.

             #### Knowledge Base
             """

    assert """
           ## Example title

           Foo:

           ### ![[Nested.Example#Description]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Description

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y
             """

    assert """
           ## Example title

           ### Foo

           bar

           ### ![[Nested.Example#Description]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Foo

             bar

             ### Description

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y
             """

    assert """
           ## Example title

           Foo:

           ### ![[Nested.Example#Notes]]

           This text should appear at the end of the transcluded content.
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:

             ### Notes

             #### Example note

             Here we have an example note with some text.

             ------------------------------------------------------------------------

             This text should appear at the end of the transcluded content.
             """

    assert """
           # ![[Project]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             # Some project

             ## Description

             This is the project description.

             ## Knowledge Base
             """

    assert """
           ## ![[Nested.Example#Notes]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Notes

             ### Example note

             Here we have an example note with some text.

             ------------------------------------------------------------------------
             """
  end

  @tag vault_files: ["concepts/Project.md"]
  test "custom header transclusion with empty content" do
    assert """
           ## Example title

           Foo:

           ### This should be removed ![[Project#Knowledge Base]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:
             """
  end

  @tag vault_files: ["concepts/Project.md"]
  test "empty header transclusion with empty content" do
    assert """
           ## Example title

           Foo:

           ### ![[Project#Knowledge Base]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Foo:
             """
  end

  @tag vault_files: ["plain/Document.md"]
  test "plain Markdown documents" do
    assert """
           ## Example title

           ![[Document]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### ![[Document]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
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
           |> Section.to_markdown() ==
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
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### Alt. title ![[Document#Title]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """
  end

  @tag vault_files: ["plain/DocumentWithPrologue.md"]
  test "plain Markdown document with prologue" do
    assert """
           ## Example title

           ![[DocumentWithPrologue]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This prologue will be ignored on header transclusions.

             ### Title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### ![[DocumentWithPrologue]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### Alt. title ![[DocumentWithPrologue]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """
  end

  @tag vault_files: ["plain/DocumentWithoutSections.md"]
  test "plain Markdown document without sections" do
    assert """
           ## Example title

           ![[DocumentWithoutSections]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### Alt. title ![[DocumentWithoutSections]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### ![[DocumentWithoutSections]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### DocumentWithoutSections

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """
  end

  @tag vault_files: "plain/DocumentWithoutFrontmatter.md"
  test "plain Markdown documents without frontmatter" do
    assert """
           ## Example title

           ![[DocumentWithoutFrontmatter]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### ![[DocumentWithoutFrontmatter]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### Alt. title ![[DocumentWithoutFrontmatter]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ![[DocumentWithoutFrontmatter#Title]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """

    assert """
           ## Example title

           ### Alt. title ![[DocumentWithoutFrontmatter#Title]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """
  end

  @tag vault_files: "plain/DocumentWithMultipleMainSections.md"
  test "documents with multiple top-level section" do
    assert """
           ## Example title

           ![[DocumentWithMultipleMainSections]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.

             ### Reference

             This is another top-level section.
             """

    assert """
           ## Example title

           ### ![[DocumentWithMultipleMainSections]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

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
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             #### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.

             #### Reference

             This is another top-level section.
             """

    assert """
           ## Example title

           ### Alt. title ![[DocumentWithMultipleMainSections#Reference]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Alt. title

             This is another top-level section.
             """

    assert """
           ## Example title

           ![[DocumentWithMultipleMainSections#Title]]
           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is an ordinary Markdown document, i.e. a document without a `magma_type`.

             ### Section

             Deserunt amet velit consequat exercitation cillum nisi nisi.
             """
  end

  @tag vault_files: [
         "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
         "concepts/modules/Nested/Nested.Example.md"
       ]
  test "prologue of Magma.Documents is ignored" do
    assert """
           ## Example title

           ![[Prompt for ModuleDoc of Nested.Example]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### System prompt

             You are an assistent for writing Elixir moduledocs.

             ### Request

             Generate a moduledoc for `Nested.Example`.
             """
  end

  @tag vault_files: ["concepts/Project.md"]
  test "when the same document is transcluded multiple times" do
    assert """
           ## Example title

           ![[Project#Description]]

           ![[Project#Knowledge Base]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             This is the project description.
             """

    assert """
           ## Example title

           ### ![[Project#Description]]

           ### ![[Project#Knowledge Base]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### Description

             This is the project description.
             """
  end

  @tag vault_files: [
         "concepts/modules/Nested/Nested.Example.md",
         "concepts/modules/Some/Some.DocumentWithTransclusion.md",
         "concepts/Project.md"
       ]
  test "recursive transclusion resolution" do
    assert """
           ## Example title

           ### ![[Some.DocumentWithTransclusion]]

           """
           |> section()
           |> Section.resolve_transclusions()
           |> Section.to_markdown() ==
             """
             ## Example title

             ### `Some.DocumentWithTransclusion`

             #### Description

             This is an example description of the module:

             `Nested.Example` is relevant so we include its description

             This is an example description of the module:

             Module `Nested.Example` does:

             -   x
             -   y

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

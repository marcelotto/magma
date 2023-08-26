defmodule Magma.DocumentStruct.SectionTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  describe "to_string/2" do
    test "single section (without header)" do
      assert """
             ## Setup

             Foo
             """
             |> section()
             |> Section.to_string() == "Foo\n"
    end

    test "single section (with header)" do
      content = """
      ## Setup

      Foo
      """

      assert content
             |> section()
             |> Section.to_string(header: true) == content
    end

    test "with subsections" do
      content = """
      ## Setup

      Foo

      ### Subsection 1

      Labore enim excepteur aute veniam.

      #### Subsection 1.2

      Lorem consequat amet minim pariatur, dolore ut.

      ### Subsection 2

      Nisi do voluptate esse culpa sint.
      """

      assert content
             |> section()
             |> Section.to_string(header: true) == content

      assert content
             |> section()
             |> Section.to_string(subsections: false) == "Foo\n"
    end
  end
end

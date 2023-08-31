defmodule Magma.DocumentStruct.SectionTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  @content_without_subsections """
  ## Setup

  Foo
  """

  @content_with_subsections """
  ## Setup

  Foo

  ### Subsection 1

  Labore enim excepteur aute veniam.

  #### Subsection 1.2

  Lorem consequat amet minim pariatur, dolore ut.

  ### Subsection 2

  Nisi do voluptate esse culpa sint.
  """

  @section_without_subsections section(@content_without_subsections)
  @section_with_subsections section(@content_with_subsections)

  describe "to_string/2" do
    test "single section (without header)" do
      assert Section.to_string(@section_without_subsections) == "Foo\n"
    end

    test "single section (with header)" do
      assert Section.to_string(@section_without_subsections, header: true) ==
               @content_without_subsections
    end

    test "with subsections" do
      assert Section.to_string(@section_with_subsections, header: true) ==
               @content_with_subsections

      assert Section.to_string(@section_with_subsections, subsections: false) ==
               "Foo\n"
    end
  end
end

defmodule Magma.DocumentStruct.SectionTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct.Section

  alias Magma.DocumentStruct.Section

  describe "to_string/2" do
    test "single section (without header)" do
      assert Section.to_string(section(:without_subsections)) == "Foo\n"
    end

    test "single section (with header)" do
      assert Section.to_string(section(:without_subsections), header: true) ==
               content_without_subsections()
    end

    test "with subsections" do
      assert Section.to_string(section(:with_subsections), header: true) ==
               content_with_subsections()

      assert Section.to_string(section(:with_subsections), subsections: false) ==
               "Foo\n"
    end
  end
end

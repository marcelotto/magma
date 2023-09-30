defmodule Magma.DocumentStructTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.Section

  test "key-based access" do
    {:ok, _metadata, body} =
      "documents/concepts/modules/Nested/Nested.Example.md"
      |> TestData.path()
      |> YamlFrontMatter.parse_file()

    assert {:ok, document_struct} = DocumentStruct.parse(body)

    assert get_in(document_struct, [
             "Artefacts",
             "ModuleDoc",
             "ModuleDoc prompt task"
           ]) ==
             %DocumentStruct.Section{
               content: [
                 %Panpipe.AST.Para{
                   children: [
                     %Panpipe.AST.Str{parent: nil, string: "Generate"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "documentation"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "for"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "module"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Code{
                       parent: nil,
                       string: "Nested.Example",
                       attr: %Panpipe.AST.Attr{identifier: "", classes: [], key_value_pairs: %{}}
                     },
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "according"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "to"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "its"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "description"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "and"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "code"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "in"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "the"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "knowledge"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "base"},
                     %Panpipe.AST.Space{parent: nil},
                     %Panpipe.AST.Str{parent: nil, string: "below."}
                   ],
                   parent: nil
                 }
               ],
               header: %Panpipe.AST.Header{
                 attr: %Panpipe.AST.Attr{
                   classes: [],
                   identifier: "moduledoc-prompt-task",
                   key_value_pairs: %{}
                 },
                 children: [
                   %Panpipe.AST.Str{parent: nil, string: "ModuleDoc"},
                   %Panpipe.AST.Space{parent: nil},
                   %Panpipe.AST.Str{parent: nil, string: "prompt"},
                   %Panpipe.AST.Space{parent: nil},
                   %Panpipe.AST.Str{parent: nil, string: "task"}
                 ],
                 level: 3,
                 parent: nil
               },
               level: 3,
               sections: [],
               title: "ModuleDoc prompt task"
             }
  end

  describe "section_by_title/1" do
    test "unnested" do
      assert %Section{title: "Example title"} =
               document_struct(:without_subsections)
               |> DocumentStruct.section_by_title("Example title")
    end

    test "nested" do
      assert %Section{title: "Subsection 1"} =
               document_struct(:with_subsections)
               |> DocumentStruct.section_by_title("Subsection 1")

      assert %Section{title: "Subsection 1.2"} =
               document_struct(:with_subsections)
               |> DocumentStruct.section_by_title("Subsection 1.2")

      assert %Section{title: "Subsection 2"} =
               document_struct(:with_subsections)
               |> DocumentStruct.section_by_title("Subsection 2")
    end

    test "when no section could be found" do
      assert document_struct(:without_subsections)
             |> DocumentStruct.section_by_title("No existing") == nil
    end
  end
end

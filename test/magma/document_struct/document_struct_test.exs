defmodule Magma.DocumentStructTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct

  alias Magma.DocumentStruct

  test "key-based access" do
    {:ok, _metadata, body} =
      "documents/__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
      |> TestData.path()
      |> YamlFrontMatter.parse_file()

    assert {:ok, document_struct} = DocumentStruct.parse(body)

    assert get_in(document_struct, ["Artefacts", "Commons", "Spec", "Expertise"]) ==
             %DocumentStruct.Section{
               title: "Expertise",
               header: %Panpipe.AST.Header{
                 children: [%Panpipe.AST.Str{parent: nil, string: "Expertise"}],
                 parent: nil,
                 level: 4,
                 attr: %Panpipe.AST.Attr{
                   identifier: "expertise",
                   classes: [],
                   key_value_pairs: %{}
                 }
               },
               level: 4,
               content: [
                 %Panpipe.AST.BulletList{
                   children: [
                     %Panpipe.AST.ListElement{
                       children: [
                         %Panpipe.AST.Plain{
                           children: [
                             %Panpipe.AST.Str{parent: nil, string: "<%="},
                             %Panpipe.AST.Space{parent: nil},
                             %Panpipe.AST.Str{parent: nil, string: "project.expertise"},
                             %Panpipe.AST.Space{parent: nil},
                             %Panpipe.AST.Str{parent: nil, string: "%>"}
                           ],
                           parent: nil
                         }
                       ],
                       parent: nil
                     },
                     %Panpipe.AST.ListElement{
                       children: [
                         %Panpipe.AST.Plain{
                           children: [
                             %Panpipe.AST.Str{parent: nil, string: "Some"},
                             %Panpipe.AST.Space{parent: nil},
                             %Panpipe.AST.Str{parent: nil, string: "additional"},
                             %Panpipe.AST.Space{parent: nil},
                             %Panpipe.AST.Str{parent: nil, string: "expertise"}
                           ],
                           parent: nil
                         }
                       ],
                       parent: nil
                     }
                   ],
                   parent: nil
                 }
               ],
               sections: []
             }
  end
end
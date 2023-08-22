defmodule Magma.DocumentStruct.ParserTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct.Parser

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.{Parser, Section}

  test "with no content" do
    assert Parser.parse("") ==
             {:ok,
              %DocumentStruct{
                prologue: [],
                sections: []
              }}

    assert Parser.parse("  ") ==
             {:ok,
              %DocumentStruct{
                prologue: [],
                sections: []
              }}

    assert Parser.parse("\n\n") ==
             {:ok,
              %DocumentStruct{
                prologue: [],
                sections: []
              }}
  end

  test "with nested sections" do
    {:ok, _metadata, body} =
      "documents/__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
      |> TestData.path()
      |> YamlFrontMatter.parse_file()

    assert Parser.parse(body) ==
             {
               :ok,
               %Magma.DocumentStruct{
                 prologue: [],
                 sections: [
                   {
                     "`Some.DocumentWithFrontMatter`",
                     %Section{
                       content: [],
                       header: %Panpipe.AST.Header{
                         attr: %Panpipe.AST.Attr{
                           classes: [],
                           identifier: "some.documentwithfrontmatter",
                           key_value_pairs: %{}
                         },
                         children: [
                           %Panpipe.AST.Code{
                             attr: %Panpipe.AST.Attr{
                               classes: [],
                               identifier: "",
                               key_value_pairs: %{}
                             },
                             parent: nil,
                             string: "Some.DocumentWithFrontMatter"
                           }
                         ],
                         level: 1,
                         parent: nil
                       },
                       level: 1,
                       sections: [
                         {
                           "Description",
                           %Section{
                             content: [
                               %Panpipe.AST.Para{
                                 children: [
                                   %Panpipe.AST.Str{parent: nil, string: "This"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "is"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "an"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "example"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "description"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "of"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "the"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "module:"}
                                 ],
                                 parent: nil
                               },
                               %Panpipe.AST.Para{
                                 children: [
                                   %Panpipe.AST.Str{parent: nil, string: "Module"},
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Code{
                                     attr: %Panpipe.AST.Attr{
                                       classes: [],
                                       identifier: "",
                                       key_value_pairs: %{}
                                     },
                                     parent: nil,
                                     string: "Some.DocumentWithFrontMatter"
                                   },
                                   %Panpipe.AST.Space{parent: nil},
                                   %Panpipe.AST.Str{parent: nil, string: "does:"}
                                 ],
                                 parent: nil
                               },
                               %Panpipe.AST.BulletList{
                                 children: [
                                   %Panpipe.AST.ListElement{
                                     children: [
                                       %Panpipe.AST.Plain{
                                         children: [%Panpipe.AST.Str{parent: nil, string: "x"}],
                                         parent: nil
                                       }
                                     ],
                                     parent: nil
                                   },
                                   %Panpipe.AST.ListElement{
                                     children: [
                                       %Panpipe.AST.Plain{
                                         children: [%Panpipe.AST.Str{parent: nil, string: "y"}],
                                         parent: nil
                                       }
                                     ],
                                     parent: nil
                                   }
                                 ],
                                 parent: nil
                               },
                               %Panpipe.AST.HorizontalRule{children: [], parent: nil}
                             ],
                             header: %Panpipe.AST.Header{
                               attr: %Panpipe.AST.Attr{
                                 classes: [],
                                 identifier: "description",
                                 key_value_pairs: %{}
                               },
                               children: [%Panpipe.AST.Str{parent: nil, string: "Description"}],
                               level: 2,
                               parent: nil
                             },
                             level: 2,
                             sections: [],
                             title: "Description"
                           }
                         },
                         {
                           "Notes",
                           %Section{
                             content: [],
                             header: %Panpipe.AST.Header{
                               attr: %Panpipe.AST.Attr{
                                 classes: [],
                                 identifier: "notes",
                                 key_value_pairs: %{}
                               },
                               children: [%Panpipe.AST.Str{parent: nil, string: "Notes"}],
                               level: 2,
                               parent: nil
                             },
                             level: 2,
                             sections: [
                               {
                                 "Example note",
                                 %Section{
                                   content: [
                                     %Panpipe.AST.Para{
                                       children: [
                                         %Panpipe.AST.Str{parent: nil, string: "Here"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "we"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "have"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "an"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "example"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "note"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "with"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "some"},
                                         %Panpipe.AST.Space{parent: nil},
                                         %Panpipe.AST.Str{parent: nil, string: "text."}
                                       ],
                                       parent: nil
                                     },
                                     %Panpipe.AST.HorizontalRule{children: [], parent: nil}
                                   ],
                                   header: %Panpipe.AST.Header{
                                     attr: %Panpipe.AST.Attr{
                                       classes: [],
                                       identifier: "example-note",
                                       key_value_pairs: %{}
                                     },
                                     children: [
                                       %Panpipe.AST.Str{parent: nil, string: "Example"},
                                       %Panpipe.AST.Space{parent: nil},
                                       %Panpipe.AST.Str{parent: nil, string: "note"}
                                     ],
                                     level: 3,
                                     parent: nil
                                   },
                                   level: 3,
                                   sections: [],
                                   title: "Example note"
                                 }
                               }
                             ],
                             title: "Notes"
                           }
                         }
                       ],
                       title: "`Some.DocumentWithFrontMatter`"
                     }
                   },
                   {"Artefacts",
                    %Section{
                      title: "Artefacts",
                      header: %Panpipe.AST.Header{
                        children: [%Panpipe.AST.Str{parent: nil, string: "Artefacts"}],
                        parent: nil,
                        level: 1,
                        attr: %Panpipe.AST.Attr{
                          identifier: "artefacts",
                          classes: [],
                          key_value_pairs: %{}
                        }
                      },
                      level: 1,
                      content: [],
                      sections: [
                        {"Commons",
                         %Section{
                           title: "Commons",
                           header: %Panpipe.AST.Header{
                             children: [%Panpipe.AST.Str{parent: nil, string: "Commons"}],
                             parent: nil,
                             level: 2,
                             attr: %Panpipe.AST.Attr{
                               identifier: "commons",
                               classes: [],
                               key_value_pairs: %{}
                             }
                           },
                           level: 2,
                           content: [],
                           sections: [
                             {"Spec",
                              %Section{
                                title: "Spec",
                                header: %Panpipe.AST.Header{
                                  children: [%Panpipe.AST.Str{parent: nil, string: "Spec"}],
                                  parent: nil,
                                  level: 3,
                                  attr: %Panpipe.AST.Attr{
                                    identifier: "spec",
                                    classes: [],
                                    key_value_pairs: %{}
                                  }
                                },
                                level: 3,
                                content: [],
                                sections: [
                                  {"Expertise",
                                   %Section{
                                     title: "Expertise",
                                     header: %Panpipe.AST.Header{
                                       children: [
                                         %Panpipe.AST.Str{parent: nil, string: "Expertise"}
                                       ],
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
                                                   %Panpipe.AST.Str{
                                                     parent: nil,
                                                     string: "project.expertise"
                                                   },
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
                                                   %Panpipe.AST.Str{
                                                     parent: nil,
                                                     string: "additional"
                                                   },
                                                   %Panpipe.AST.Space{parent: nil},
                                                   %Panpipe.AST.Str{
                                                     parent: nil,
                                                     string: "expertise"
                                                   }
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
                                   }}
                                ]
                              }}
                           ]
                         }}
                      ]
                    }}
                 ]
               }
             }
  end

  test "with multiple top-level sections" do
    assert """
           # Section 1

           Ex lorem proident esse.

           # Section 2

           Enim cillum, reprehenderit laboris.

           ## Subsection

           Fugiat eu non exercitation et lorem fugiat dolor.
           """
           |> Parser.parse() ==
             {:ok,
              %DocumentStruct{
                prologue: [],
                sections: [
                  {
                    "Section 1",
                    %Section{
                      content: [
                        %Panpipe.AST.Para{
                          children: [
                            %Panpipe.AST.Str{parent: nil, string: "Ex"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "lorem"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "proident"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "esse."}
                          ],
                          parent: nil
                        }
                      ],
                      header: %Panpipe.AST.Header{
                        attr: %Panpipe.AST.Attr{
                          classes: [],
                          identifier: "section-1",
                          key_value_pairs: %{}
                        },
                        children: [
                          %Panpipe.AST.Str{parent: nil, string: "Section"},
                          %Panpipe.AST.Space{parent: nil},
                          %Panpipe.AST.Str{parent: nil, string: "1"}
                        ],
                        level: 1,
                        parent: nil
                      },
                      level: 1,
                      sections: [],
                      title: "Section 1"
                    }
                  },
                  {
                    "Section 2",
                    %Section{
                      content: [
                        %Panpipe.AST.Para{
                          children: [
                            %Panpipe.AST.Str{parent: nil, string: "Enim"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "cillum,"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "reprehenderit"},
                            %Panpipe.AST.Space{parent: nil},
                            %Panpipe.AST.Str{parent: nil, string: "laboris."}
                          ],
                          parent: nil
                        }
                      ],
                      header: %Panpipe.AST.Header{
                        attr: %Panpipe.AST.Attr{
                          classes: [],
                          identifier: "section-2",
                          key_value_pairs: %{}
                        },
                        children: [
                          %Panpipe.AST.Str{parent: nil, string: "Section"},
                          %Panpipe.AST.Space{parent: nil},
                          %Panpipe.AST.Str{parent: nil, string: "2"}
                        ],
                        level: 1,
                        parent: nil
                      },
                      title: "Section 2",
                      level: 1,
                      sections: [
                        {"Subsection",
                         %Section{
                           title: "Subsection",
                           header: %Panpipe.AST.Header{
                             children: [%Panpipe.AST.Str{parent: nil, string: "Subsection"}],
                             parent: nil,
                             level: 2,
                             attr: %Panpipe.AST.Attr{
                               identifier: "subsection",
                               classes: [],
                               key_value_pairs: %{}
                             }
                           },
                           level: 2,
                           content: [
                             %Panpipe.AST.Para{
                               children: [
                                 %Panpipe.AST.Str{parent: nil, string: "Fugiat"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "eu"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "non"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "exercitation"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "et"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "lorem"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "fugiat"},
                                 %Panpipe.AST.Space{parent: nil},
                                 %Panpipe.AST.Str{parent: nil, string: "dolor."}
                               ],
                               parent: nil
                             }
                           ],
                           sections: []
                         }}
                      ]
                    }
                  }
                ]
              }}
  end

  test "with prologue" do
    assert """
           This is some text without a header.

           It can span multiples paragraphs.

           #  Title

           Here the actual document content starts.
           """
           |> Parser.parse() ==
             {:ok,
              %DocumentStruct{
                prologue: [
                  %Panpipe.AST.Para{
                    children: [
                      %Panpipe.AST.Str{parent: nil, string: "This"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "is"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "some"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "text"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "without"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "a"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "header."}
                    ],
                    parent: nil
                  },
                  %Panpipe.AST.Para{
                    children: [
                      %Panpipe.AST.Str{parent: nil, string: "It"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "can"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "span"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "multiples"},
                      %Panpipe.AST.Space{parent: nil},
                      %Panpipe.AST.Str{parent: nil, string: "paragraphs."}
                    ],
                    parent: nil
                  }
                ],
                sections: [
                  {"Title",
                   %Section{
                     title: "Title",
                     header: %Panpipe.AST.Header{
                       children: [%Panpipe.AST.Str{parent: nil, string: "Title"}],
                       parent: nil,
                       level: 1,
                       attr: %Panpipe.AST.Attr{
                         identifier: "title",
                         classes: [],
                         key_value_pairs: %{}
                       }
                     },
                     level: 1,
                     content: [
                       %Panpipe.AST.Para{
                         children: [
                           %Panpipe.AST.Str{parent: nil, string: "Here"},
                           %Panpipe.AST.Space{parent: nil},
                           %Panpipe.AST.Str{parent: nil, string: "the"},
                           %Panpipe.AST.Space{parent: nil},
                           %Panpipe.AST.Str{parent: nil, string: "actual"},
                           %Panpipe.AST.Space{parent: nil},
                           %Panpipe.AST.Str{parent: nil, string: "document"},
                           %Panpipe.AST.Space{parent: nil},
                           %Panpipe.AST.Str{parent: nil, string: "content"},
                           %Panpipe.AST.Space{parent: nil},
                           %Panpipe.AST.Str{parent: nil, string: "starts."}
                         ],
                         parent: nil
                       }
                     ],
                     sections: []
                   }}
                ]
              }}
  end
end

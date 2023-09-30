defmodule Magma.DocumentStruct.ParserTest do
  use Magma.TestCase

  doctest Magma.DocumentStruct.Parser

  alias Magma.DocumentStruct
  alias Magma.DocumentStruct.{Parser, Section}

  test "smart extension issue with header title parsing" do
    assert {:ok, %DocumentStruct{sections: [%Magma.DocumentStruct.Section{title: "'Foo'"}]}} =
             Parser.parse("# 'Foo'")
  end

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
      "documents/concepts/modules/Nested/Nested.Example.md"
      |> TestData.path()
      |> YamlFrontMatter.parse_file()

    assert Parser.parse(body) ==
             {
               :ok,
               %Magma.DocumentStruct{
                 prologue: [],
                 sections: [
                   %Magma.DocumentStruct.Section{
                     content: [],
                     header: %Panpipe.AST.Header{
                       attr: %Panpipe.AST.Attr{
                         classes: [],
                         identifier: "nested.example",
                         key_value_pairs: %{}
                       },
                       children: [
                         %Panpipe.AST.Code{
                           attr: %Panpipe.AST.Attr{
                             classes: [],
                             identifier: "",
                             key_value_pairs: %{}
                           },
                           string: "Nested.Example"
                         }
                       ],
                       level: 1
                     },
                     level: 1,
                     sections: [
                       %Magma.DocumentStruct.Section{
                         content: [
                           %Panpipe.AST.Para{
                             children: [
                               %Panpipe.AST.Str{string: "This"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "is"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "an"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "example"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "description"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "of"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "the"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "module:"}
                             ]
                           },
                           %Panpipe.AST.Para{
                             children: [
                               %Panpipe.AST.Str{string: "Module"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Code{
                                 attr: %Panpipe.AST.Attr{
                                   classes: [],
                                   identifier: "",
                                   key_value_pairs: %{}
                                 },
                                 string: "Nested.Example"
                               },
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "does:"}
                             ]
                           },
                           %Panpipe.AST.BulletList{
                             children: [
                               %Panpipe.AST.ListElement{
                                 children: [
                                   %Panpipe.AST.Plain{
                                     children: [%Panpipe.AST.Str{string: "x"}]
                                   }
                                 ]
                               },
                               %Panpipe.AST.ListElement{
                                 children: [
                                   %Panpipe.AST.Plain{
                                     children: [%Panpipe.AST.Str{string: "y"}]
                                   }
                                 ]
                               }
                             ]
                           }
                         ],
                         header: %Panpipe.AST.Header{
                           attr: %Panpipe.AST.Attr{
                             classes: [],
                             identifier: "description",
                             key_value_pairs: %{}
                           },
                           children: [%Panpipe.AST.Str{string: "Description"}],
                           level: 2
                         },
                         level: 2,
                         sections: [],
                         title: "Description"
                       }
                     ],
                     title: "`Nested.Example`"
                   },
                   %Magma.DocumentStruct.Section{
                     content: [
                       %Panpipe.AST.RawBlock{
                         children: [],
                         format: "html",
                         string:
                           "<!--\nThis section should include background knowledge needed for the model to create a proper response, i.e. information it does know either because of the knowledge cut-off date or unpublished knowledge.\n\nWrite it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.\n-->"
                       }
                     ],
                     header: %Panpipe.AST.Header{
                       attr: %Panpipe.AST.Attr{
                         classes: [],
                         identifier: "context-knowledge",
                         key_value_pairs: %{}
                       },
                       children: [
                         %Panpipe.AST.Str{string: "Context"},
                         %Panpipe.AST.Space{},
                         %Panpipe.AST.Str{string: "knowledge"}
                       ],
                       level: 1
                     },
                     level: 1,
                     sections: [
                       %Magma.DocumentStruct.Section{
                         content: [
                           %Panpipe.AST.Para{
                             children: [
                               %Panpipe.AST.Str{string: "Nostrud"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "qui"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "magna"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "officia"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "consequat"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "consectetur"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "dolore"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "sed"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "amet"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "eiusmod"}
                             ]
                           }
                         ],
                         header: %Panpipe.AST.Header{
                           attr: %Panpipe.AST.Attr{
                             classes: [],
                             identifier: "some-background-knowledge",
                             key_value_pairs: %{}
                           },
                           children: [
                             %Panpipe.AST.Str{string: "Some"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Str{string: "background"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Str{string: "knowledge"}
                           ],
                           level: 2
                         },
                         level: 2,
                         sections: [],
                         title: "Some background knowledge"
                       },
                       %Magma.DocumentStruct.Section{
                         content: [],
                         header: %Panpipe.AST.Header{
                           attr: %Panpipe.AST.Attr{
                             classes: [],
                             identifier: "transcluded-background-knowledge",
                             key_value_pairs: %{}
                           },
                           children: [
                             %Panpipe.AST.Str{string: "Transcluded"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Str{string: "background"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Str{string: "knowledge"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Image{
                               children: [%Panpipe.AST.Str{string: ""}],
                               target: "Document#Title",
                               title: "wikilink",
                               attr: %Panpipe.AST.Attr{
                                 identifier: "",
                                 classes: [],
                                 key_value_pairs: %{}
                               }
                             }
                           ],
                           level: 2
                         },
                         level: 2,
                         sections: [],
                         title: "Transcluded background knowledge ![[Document#Title|]]"
                       }
                     ],
                     title: "Context knowledge"
                   },
                   %Magma.DocumentStruct.Section{
                     title: "Notes",
                     header: %Panpipe.AST.Header{
                       children: [%Panpipe.AST.Str{string: "Notes"}],
                       level: 1,
                       attr: %Panpipe.AST.Attr{
                         identifier: "notes",
                         classes: [],
                         key_value_pairs: %{}
                       }
                     },
                     level: 1,
                     content: [],
                     sections: [
                       %Magma.DocumentStruct.Section{
                         title: "Example note",
                         header: %Panpipe.AST.Header{
                           children: [
                             %Panpipe.AST.Str{string: "Example"},
                             %Panpipe.AST.Space{},
                             %Panpipe.AST.Str{string: "note"}
                           ],
                           level: 2,
                           attr: %Panpipe.AST.Attr{
                             identifier: "example-note",
                             classes: [],
                             key_value_pairs: %{}
                           }
                         },
                         level: 2,
                         content: [
                           %Panpipe.AST.Para{
                             children: [
                               %Panpipe.AST.Str{string: "Here"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "we"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "have"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "an"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "example"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "note"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "with"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "some"},
                               %Panpipe.AST.Space{},
                               %Panpipe.AST.Str{string: "text."}
                             ]
                           },
                           %Panpipe.AST.HorizontalRule{children: []}
                         ],
                         sections: []
                       }
                     ]
                   },
                   %Magma.DocumentStruct.Section{
                     title: "Artefacts",
                     header: %Panpipe.AST.Header{
                       children: [%Panpipe.AST.Str{string: "Artefacts"}],
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
                       %Magma.DocumentStruct.Section{
                         title: "ModuleDoc",
                         header: %Panpipe.AST.Header{
                           children: [%Panpipe.AST.Str{string: "ModuleDoc"}],
                           level: 2,
                           attr: %Panpipe.AST.Attr{
                             identifier: "moduledoc",
                             classes: [],
                             key_value_pairs: %{}
                           }
                         },
                         level: 2,
                         content: [],
                         sections: [
                           %Magma.DocumentStruct.Section{
                             title: "ModuleDoc prompt task",
                             header: %Panpipe.AST.Header{
                               children: [
                                 %Panpipe.AST.Str{string: "ModuleDoc"},
                                 %Panpipe.AST.Space{},
                                 %Panpipe.AST.Str{string: "prompt"},
                                 %Panpipe.AST.Space{},
                                 %Panpipe.AST.Str{string: "task"}
                               ],
                               level: 3,
                               attr: %Panpipe.AST.Attr{
                                 identifier: "moduledoc-prompt-task",
                                 classes: [],
                                 key_value_pairs: %{}
                               }
                             },
                             level: 3,
                             content: [
                               %Panpipe.AST.Para{
                                 children: [
                                   %Panpipe.AST.Str{string: "Generate"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "documentation"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "for"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "module"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Code{
                                     string: "Nested.Example",
                                     attr: %Panpipe.AST.Attr{
                                       identifier: "",
                                       classes: [],
                                       key_value_pairs: %{}
                                     }
                                   },
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "according"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "to"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "its"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "description"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "and"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "code"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "in"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "the"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "knowledge"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "base"},
                                   %Panpipe.AST.Space{},
                                   %Panpipe.AST.Str{string: "below."}
                                 ]
                               }
                             ],
                             sections: []
                           }
                         ]
                       }
                     ]
                   }
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
                  %Section{
                    content: [
                      %Panpipe.AST.Para{
                        children: [
                          %Panpipe.AST.Str{string: "Ex"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "lorem"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "proident"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "esse."}
                        ]
                      }
                    ],
                    header: %Panpipe.AST.Header{
                      attr: %Panpipe.AST.Attr{
                        classes: [],
                        identifier: "section-1",
                        key_value_pairs: %{}
                      },
                      children: [
                        %Panpipe.AST.Str{string: "Section"},
                        %Panpipe.AST.Space{},
                        %Panpipe.AST.Str{string: "1"}
                      ],
                      level: 1
                    },
                    level: 1,
                    sections: [],
                    title: "Section 1"
                  },
                  %Section{
                    content: [
                      %Panpipe.AST.Para{
                        children: [
                          %Panpipe.AST.Str{string: "Enim"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "cillum,"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "reprehenderit"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "laboris."}
                        ]
                      }
                    ],
                    header: %Panpipe.AST.Header{
                      attr: %Panpipe.AST.Attr{
                        classes: [],
                        identifier: "section-2",
                        key_value_pairs: %{}
                      },
                      children: [
                        %Panpipe.AST.Str{string: "Section"},
                        %Panpipe.AST.Space{},
                        %Panpipe.AST.Str{string: "2"}
                      ],
                      level: 1
                    },
                    title: "Section 2",
                    level: 1,
                    sections: [
                      %Section{
                        title: "Subsection",
                        header: %Panpipe.AST.Header{
                          children: [%Panpipe.AST.Str{string: "Subsection"}],
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
                              %Panpipe.AST.Str{string: "Fugiat"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "eu"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "non"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "exercitation"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "et"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "lorem"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "fugiat"},
                              %Panpipe.AST.Space{},
                              %Panpipe.AST.Str{string: "dolor."}
                            ]
                          }
                        ],
                        sections: []
                      }
                    ]
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
                      %Panpipe.AST.Str{string: "This"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "is"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "some"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "text"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "without"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "a"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "header."}
                    ]
                  },
                  %Panpipe.AST.Para{
                    children: [
                      %Panpipe.AST.Str{string: "It"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "can"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "span"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "multiples"},
                      %Panpipe.AST.Space{},
                      %Panpipe.AST.Str{string: "paragraphs."}
                    ]
                  }
                ],
                sections: [
                  %Section{
                    title: "Title",
                    header: %Panpipe.AST.Header{
                      children: [%Panpipe.AST.Str{string: "Title"}],
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
                          %Panpipe.AST.Str{string: "Here"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "the"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "actual"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "document"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "content"},
                          %Panpipe.AST.Space{},
                          %Panpipe.AST.Str{string: "starts."}
                        ]
                      }
                    ],
                    sections: []
                  }
                ]
              }}
  end
end

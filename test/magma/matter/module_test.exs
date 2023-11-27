defmodule Magma.Matter.ModuleTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Matter.Module

  alias Magma.{Concept, Matter, Artefact, Artefacts}

  describe "code/1" do
    test "returns the code of the given module" do
      assert Matter.Module.code(TopLevelExample) ==
               File.read!("test/modules/top_level_example.ex")

      assert Matter.Module.code(Nested.Example) ==
               File.read!("test/modules/nested/example.ex")
    end

    test "not a module" do
      assert Matter.Module.code(:foo) == nil
    end

    test "code not present" do
      assert Matter.Module.code(Mix) == nil
    end
  end

  test "context_modules/2" do
    assert Matter.Module.context_modules(Magma) == []
    assert Matter.Module.context_modules(Magma.Document) == [Magma]

    assert Matter.Module.context_modules(Magma.DocumentStruct.Section) == [
             Magma,
             Magma.DocumentStruct
           ]

    assert Matter.Module.context_modules(Magma.Matter.Text.Section) == [
             Magma,
             Magma.Matter,
             Magma.Matter.Text
           ]
  end

  @tag vault_files: ["concepts/modules/Nested/Nested.Example.md"]
  test "submodules/1" do
    assert Matter.Module.submodules(Nested) ==
             [Nested.Example]
  end

  test "ignore?/1" do
    assert Matter.Module.ignore?(Magma.DocumentStruct.Parser)
    refute Matter.Module.ignore?(Matter.Module)
    refute Matter.Module.ignore?(TopLevelExample)
    refute Matter.Module.ignore?(Nested.Example)
  end

  @tag vault_files: ["concepts/Project.md"]
  test "Concept creation" do
    expected_path = Vault.path("concepts/modules/Nested/Nested.Example.md")

    refute File.exists?(expected_path)

    assert {:ok,
            %Concept{
              subject: %Matter.Module{name: Nested.Example},
              name: "Nested.Example",
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{},
              title: "`Nested.Example`",
              prologue: []
            } = concept} =
             Nested.Example
             |> Matter.Module.new!()
             |> Concept.create()

    assert concept.path == expected_path
    assert is_just_now(concept.created_at)

    assert concept.content ==
             """
             # `Nested.Example`

             ## Description

             <!--
             What is a `Nested.Example`?

             Your knowledge about the module, i.e. facts, problems and properties etc.
             -->


             # Context knowledge

             <!--
             This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

             Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
             -->




             # Artefacts

             ## ModuleDoc

             - Prompt: [[Prompt for ModuleDoc of Nested.Example]]
             - Final version: [[ModuleDoc of Nested.Example]]

             ### ModuleDoc prompt task

             Generate documentation for module `Nested.Example` according to its description and code in the knowledge base below.
             """

    assert Concept.load(concept.path) == {:ok, concept}

    assert Vault.document_path(concept.name) == concept.path

    # prompts are created
    assert {:ok, %Artefact.Prompt{}} =
             concept
             |> Artefacts.ModuleDoc.new!()
             |> Artefact.Prompt.new!()
             |> Artefact.Prompt.load()
  end

  @tag vault_files: "concepts/modules/Nested/Nested.Example.md"
  test "Concept loading", %{vault_files: vault_file} do
    document_path = Vault.path(vault_file)

    assert {
             :ok,
             %Magma.Concept{
               subject: %Matter.Module{name: Nested.Example},
               path: ^document_path,
               name: "Nested.Example",
               content: content,
               custom_metadata: %{},
               aliases: [],
               tags: ["foo", "bar"],
               created_at: ~N[2023-07-11 14:25:00],
               title: "`Nested.Example`",
               prologue: []
             } = concept
           } = Concept.load(document_path)

    assert File.exists?(document_path)

    assert document_path
           |> File.read!()
           |> String.trim()
           |> String.ends_with?(String.trim(content))

    assert Nested.Example
           |> Matter.Module.new!()
           |> Concept.new!()
           |> Concept.load() == {:ok, concept}
  end
end

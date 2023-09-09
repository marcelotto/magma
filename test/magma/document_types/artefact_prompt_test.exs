defmodule Magma.Artefact.PromptTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Artefact.Prompt

  import ExUnit.CaptureLog

  alias Magma.{Artefacts, Artefact, Concept}

  describe "new/1" do
    test "with ModuleDoc artefact" do
      artefact = module_doc_artefact()

      assert {:ok,
              %Artefact.Prompt{
                artefact: ^artefact,
                path: path,
                name: name,
                tags: nil,
                aliases: nil,
                created_at: nil,
                custom_metadata: nil,
                content: nil
              }} = Artefact.Prompt.new(artefact)

      assert name == "Prompt for ModuleDoc of Nested.Example"

      assert path ==
               Vault.path("artefacts/generated/modules/Nested/Example/#{name}.md")
    end
  end

  describe "create/1" do
    @tag vault_files: [
           "concepts/modules/Nested/Nested.Example.md",
           "concepts/Project.md"
         ]
    test "moduledoc" do
      module_concept = Nested.Example |> module_concept() |> Concept.load!()
      artefact = Artefacts.ModuleDoc.new!(module_concept)
      prompt = Artefact.Prompt.new!(artefact)

      assert {:ok,
              %Artefact.Prompt{
                artefact: ^artefact,
                tags: ["magma-vault"],
                aliases: [],
                custom_metadata: %{}
              } = prompt} = Artefact.Prompt.create(prompt)

      assert prompt.name == "Prompt for #{artefact.name}"
      assert DateTime.diff(DateTime.utc_now(), prompt.created_at, :second) <= 2

      assert prompt.content ==
               """
               **Generated results**

               #{Magma.Obsidian.View.Helper.prompt_results_table()}
               **Actions**

               #{Magma.Obsidian.View.Helper.button("Execute", "magma.prompt.exec", color: "blue")}
               #{Magma.Obsidian.View.Helper.button("Update", "magma.prompt.update")}

               # #{prompt.name}

               ## System prompt

               You are MagmaGPT, a software developer on the "Some Project" project with a lot of experience with Elixir and writing high-quality documentation.

               Your task is to write documentation for Elixir modules.

               Specification of the responses you give:

               - Language: English
               - Format: Markdown
               - Documentation that is clear, concise and comprehensible and covers the main aspects of the requested module.
               - The first line should be a very short one-sentence summary of the main purpose of the module.
               - Generate just the comment for the module, not for its individual functions.


               ### Background knowledge of the Some Project project ![[Project#Description]]


               ## Request

               Generate documentation for module `Nested.Example`.



               <!--
               A comment ...
               -->


               ### Description of the module

               This is an example description of the module:

               Module `Nested.Example` does:

               -   x
               -   y

               ------------------------------------------------------------------------


               ### Module code

               This is the code of the module to be documented. Ignore commented out code.

               ```elixir
               defmodule Nested.Example do
                 use Magma

                 def foo, do: :bar
               end

               ```
               """
    end
  end

  describe "messages/1" do
    @describetag vault_files: [
                   "artefacts/generated/modules/Nested/Example/Prompt for ModuleDoc of Nested.Example.md",
                   "concepts/modules/Nested/Nested.Example.md",
                   "concepts/Project.md"
                 ]

    test "with one setup and one request section", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()

      assert Artefact.Prompt.messages(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 "Generate a moduledoc for `Nested.Example`.\n"
               }
    end

    test "with multiple top-level sections", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              # Another top-level section

              Foo bar
              """)
        )

      assert capture_log(fn ->
               assert Artefact.Prompt.messages(prompt) ==
                        {
                          :ok,
                          "You are an assistent for writing Elixir moduledocs.\n",
                          "Generate a moduledoc for `Nested.Example`.\n"
                        }
             end) =~ "#{prompt.name} contains subsections which won't be taken into account"
    end

    test "with other sections under the prompt section", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              ## Another top-level section

              Foo bar
              """)
        )

      assert capture_log(fn ->
               assert Artefact.Prompt.messages(prompt) ==
                        {
                          :ok,
                          "You are an assistent for writing Elixir moduledocs.\n",
                          "Generate a moduledoc for `Nested.Example`.\n"
                        }
             end) =~ "#{prompt.name} contains subsections which won't be taken into account"
    end

    test "transclusion are resolved", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              ### Background knowledge of the Some Project project ![[Project#Description]]
              """)
        )

      assert Artefact.Prompt.messages(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 """
                 Generate a moduledoc for `Nested.Example`.

                 ### Background knowledge of the Some Project project

                 This is the project description.
                 """
               }
    end

    test "comments are not rendered", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              This is a document with <!-- inline --> comments.

              <!--
              across

              multiple

              lines
              -->
              """)
        )

      assert Artefact.Prompt.messages(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 "Generate a moduledoc for `Nested.Example`.\n\nThis is a document with comments.\n"
               }
    end
  end
end

defmodule Magma.Prompt.AssemblerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Prompt.Assembler

  alias Magma.Artefact
  alias Magma.Prompt.Assembler

  import ExUnit.CaptureLog

  describe "assemble_parts/1" do
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

      assert Assembler.assemble_parts(prompt) ==
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
               assert Assembler.assemble_parts(prompt) ==
                        {
                          :ok,
                          "You are an assistent for writing Elixir moduledocs.\n",
                          "Generate a moduledoc for `Nested.Example`.\n"
                        }
             end) =~
               "Prompt #{prompt.path} contains subsections which won't be taken into account"
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
               assert Assembler.assemble_parts(prompt) ==
                        {
                          :ok,
                          "You are an assistent for writing Elixir moduledocs.\n",
                          "Generate a moduledoc for `Nested.Example`.\n"
                        }
             end) =~
               "Prompt #{prompt.path} contains subsections which won't be taken into account"
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

              ### Background knowledge of the Some project ![[Project#Description]]
              """)
        )

      assert Assembler.assemble_parts(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 """
                 Generate a moduledoc for `Nested.Example`.

                 # Background knowledge of the Some project

                 This is the project description.
                 """
               }
    end

    test "links are resolved", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Artefact.Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              [[Some link]]

              """)
        )

      assert Assembler.assemble_parts(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 """
                 Generate a moduledoc for `Nested.Example`.

                 Some link
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

      assert Assembler.assemble_parts(prompt) ==
               {
                 :ok,
                 "You are an assistent for writing Elixir moduledocs.\n",
                 "Generate a moduledoc for `Nested.Example`.\n\nThis is a document with comments.\n"
               }
    end
  end
end

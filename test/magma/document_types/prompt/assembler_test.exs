defmodule Magma.Prompt.AssemblerTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Prompt.Assembler

  alias Magma.Prompt
  alias Magma.Prompt.Assembler

  import ExUnit.CaptureLog

  describe "assemble_parts/1" do
    @describetag vault_files: [
                   "prompts/Foo-Prompt.md",
                   "plain/Document.md"
                 ]

    test "with one setup and one request section", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()

      assert Assembler.assemble_parts(prompt) ==
               {
                 :ok,
                 "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                 "Elixir is ...\n"
               }
    end

    test "with multiple top-level sections", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()
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
                          "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                          "Elixir is ...\n"
                        }
             end) =~
               "Prompt #{prompt.path} contains subsections which won't be taken into account. Put them under the task section"
    end

    test "with other sections under the prompt section", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()
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
                          "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                          "Elixir is ...\n"
                        }
             end) =~
               "Prompt #{prompt.path} contains subsections which won't be taken into account. Put them under the task section"
    end

    test "transclusion are resolved", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()
        |> Map.update!(
          :content,
          &(&1 <>
              """

              ### Background knowledge ![[Document#Section]]
              """)
        )

      assert Assembler.assemble_parts(prompt) ==
               {
                 :ok,
                 "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                 """
                 Elixir is ...

                 # Background knowledge

                 Deserunt amet velit consequat exercitation cillum nisi nisi.
                 """
               }
    end

    test "links are resolved", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()
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
                 "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                 """
                 Elixir is ...

                 Some link
                 """
               }
    end

    test "comments are not rendered", %{vault_files: [prompt_file | _]} do
      prompt =
        prompt_file
        |> Vault.path()
        |> Prompt.load!()
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
                 "You are an assistent for the Elixir language. You always answer very short with at most three words.\n",
                 "Elixir is ...\n\nThis is a document with comments.\n"
               }
    end
  end
end

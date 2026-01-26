defmodule Magma.ViewTest do
  use Magma.Vault.Case, async: false

  doctest Magma.View

  alias Magma.View

  alias Magma.Document

  describe "include/3" do
    test "with section" do
      section_content =
        """
        # Foo

        <!--
        Some comment
        -->

        ## Bar

        baz
        """

      section = section(section_content)

      assert View.include(section) == String.trim(section_content)

      assert View.include(section, "Bar") ==
               """
               ## Bar

               baz
               """
               |> String.trim()

      assert View.include(section, ["Bar"]) ==
               """
               ## Bar

               baz
               """
               |> String.trim()

      assert View.include(section, nil, header: false) ==
               """
               <!--
               Some comment
               -->

               ## Bar

               baz
               """
               |> String.trim()

      assert View.include(section, nil, level: 3) ==
               """
               ### Foo

               <!--
               Some comment
               -->

               #### Bar

               baz
               """
               |> String.trim()

      assert View.include(section, nil, remove_comments: true) ==
               """
               # Foo

               ## Bar

               baz
               """
               |> String.trim()

      assert View.include(section, nil, header: false, level: 2, remove_comments: true) ==
               """
               ### Bar

               baz
               """
               |> String.trim()
    end

    @tag vault_files: ["prompts/Foo-Prompt.md"]
    test "with document" do
      {:ok, document} = Document.Loader.load("Foo-Prompt")

      body =
        """
        # Foo-Prompt

        ## System prompt

        You are an assistent for the Elixir language. You always answer very short with at most three words.

        ## Request

        Elixir is ...
        """
        |> String.trim()

      assert View.include(document) == body

      assert View.include(document, :title) == body
      assert View.include(document, "Foo-Prompt") == body

      assert View.include(document, :all) ==
               """
               ``` button
               name Execute
               type command
               action Shell commands: Execute: magma.prompt.exec
               color blue
               ```

               #{body}
               """
               |> String.trim()

      assert View.include(document, "System prompt") ==
               """
               ## System prompt

               You are an assistent for the Elixir language. You always answer very short with at most three words.
               """
               |> String.trim()

      assert View.include(document, "System prompt", header: false) ==
               "You are an assistent for the Elixir language. You always answer very short with at most three words."

      assert View.include(document, nil, level: 3) ==
               """
               ### Foo-Prompt

               #### System prompt

               You are an assistent for the Elixir language. You always answer very short with at most three words.

               #### Request

               Elixir is ...
               """
               |> String.trim()

      assert View.include(document, "Foo-Prompt",
               header: false,
               level: 2,
               remove_comments: true
             ) ==
               """
               ### System prompt

               You are an assistent for the Elixir language. You always answer very short with at most three words.

               ### Request

               Elixir is ...
               """
               |> String.trim()
    end
  end
end

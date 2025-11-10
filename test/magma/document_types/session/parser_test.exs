defmodule Magma.Session.ParserTest do
  use ExUnit.Case, async: true

  alias Magma.Session.Parser

  @doc_with_no_separators """
  # Test Session

  This is initial session content without separators.

  ## System prompt

  You are a helpful assistant.

  ## Request prompt

  Please help me with this task.
  """

  @doc_with_response_separator """
  # Test Session

  ## System prompt

  You are a helpful assistant.

  ## Request prompt

  Please help me with this task.

  ---

  ***Response***

  ---

  WRITE_RESPONSE_HERE
  """

  @doc_with_continuation """
  # Test Session

  ## Request prompt

  Initial request.

  ---

  ***Response***

  ---

  Initial response here.

  ---

  ***Prompt***

  ---

  Follow-up request.

  Replace "WRITE_RESPONSE_HERE" with your response.

  ---

  ***Response***

  ---

  WRITE_RESPONSE_HERE
  """

  @doc_with_notes """
  # Test Session

  ---

  ***Prompt***

  ---

  First prompt here.

  ---

  ***Response***

  ---

  First response here.

  ---

  ***Notes***

  ---

  Some notes about the conversation.

  ---

  ***Prompt***

  ---

  Second prompt here.

  ---

  ***Response***

  ---

  WRITE_RESPONSE_HERE
  """

  describe "parse/1" do
    test "parses document with no separators" do
      assert {:ok, [{:initial, content}]} = Parser.parse(@doc_with_no_separators)
      assert is_list(content)
      assert length(content) > 0
    end

    test "parses document with Response separator only" do
      assert {:ok, parts} = Parser.parse(@doc_with_response_separator)
      assert [{:initial, _initial_content}, {:response, _response_content}] = parts
    end

    test "parses document with Prompt and Response separators (continuation mode)" do
      assert {:ok, parts} = Parser.parse(@doc_with_continuation)

      assert [
               {:initial, _initial},
               {:response, _response1},
               {:prompt, prompt_content},
               {:response, _response2}
             ] = parts

      # Verify the prompt content is extracted correctly
      assert is_list(prompt_content)
      assert length(prompt_content) > 0
    end

    test "parses document with mixed section types including Notes" do
      assert {:ok,
              [
                {:initial, _initial},
                {:prompt, _prompt1},
                {:response, _response1},
                {:notes, _notes},
                {:prompt, _prompt2},
                {:response, _response2}
              ]} = Parser.parse(@doc_with_notes)
    end

    test "handles malformed separator (missing horizontal rules)" do
      doc = """
      # Test

      ***Prompt***

      Some content
      """

      # Without proper HR separators, content goes to :initial part
      assert {:ok, [{:initial, _}]} = Parser.parse(doc)
    end

    test "handles separator with wrong format (not bold)" do
      doc = """
      # Test

      ---

      Prompt

      ---

      Some content
      """

      # Without Strong formatting, content goes to :initial part
      assert {:ok, [{:initial, _}]} = Parser.parse(doc)
    end

    test "returns empty initial part for empty content" do
      # Empty content results in no parts at all
      assert {:ok, []} = Parser.parse("")
    end
  end

  describe "extract_parts/1" do
    test "extracts content between separators" do
      assert {:ok, parts} = Parser.parse(@doc_with_continuation)

      # Find the first prompt part
      assert {:prompt, prompt_nodes} = Enum.find(parts, fn {type, _} -> type == :prompt end)

      # The prompt content should be AST nodes
      assert is_list(prompt_nodes)
    end

    test "preserves AST structure in extracted parts" do
      doc = """
      # Session

      ---

      ***Prompt***

      ---

      ## Subheader

      Some **bold** text with a [link](url).

      ---

      ***Response***

      ---

      Response content.
      """

      assert {:ok, [{:initial, _initial}, {:prompt, prompt_nodes}, {:response, _}]} =
               Parser.parse(doc)

      # Verify AST nodes are preserved
      assert Enum.any?(prompt_nodes, fn
               %Panpipe.AST.Header{} -> true
               _ -> false
             end)
    end
  end

  describe "section type recognition" do
    test "recognizes 'Prompt' keyword" do
      doc = """
      ---

      ***Prompt***

      ---

      Content here.
      """

      assert {:ok, [{:prompt, _}]} = Parser.parse(doc)
    end

    test "recognizes 'Response' keyword" do
      doc = """
      ---

      ***Response***

      ---

      Content here.
      """

      assert {:ok, [{:response, _}]} = Parser.parse(doc)
    end

    test "recognizes 'Notes' keyword" do
      doc = """
      ---

      ***Notes***

      ---

      Content here.
      """

      assert {:ok, [{:notes, _}]} = Parser.parse(doc)
    end

    test "case sensitive keyword matching" do
      doc = """
      ---

      ***prompt***

      ---

      Content here.
      """

      # lowercase 'prompt' should not be recognized, content goes to :initial
      assert {:ok, [{:initial, _}]} = Parser.parse(doc)
    end
  end
end

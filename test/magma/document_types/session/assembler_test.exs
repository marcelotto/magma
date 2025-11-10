defmodule Magma.Session.AssemblerTest do
  use Magma.Vault.Case, async: false

  alias Magma.Session
  alias Magma.Prompt.Assembler

  describe "assemble_all/1 - Initial Mode" do
    @describetag vault_files: ["concepts/Project.md"]
    test "compiles session like a regular Prompt" do
      # Create a new session (initial mode - no Prompt separators)
      assert {:ok, session} = Session.create("InitialModeSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      # Verify it's in initial mode
      assert Session.mode(loaded_session) == :initial

      # Assemble the prompt
      assert {:ok, compiled} = Assembler.assemble_all(loaded_session)
      assert is_binary(compiled)

      # Should contain the replacement marker instruction (from Request section)
      assert compiled =~
               "Use the Edit tool to replace the line starting with \"WRITE_RESPONSE_HERE\""

      assert compiled =~ "test/data/example_vault/sessions/InitialModeSession.md"

      # Should NOT contain the Response separator (that's in the Session document, not the compiled prompt)
      refute compiled =~ "***Response***"
    end

    test "resolves transclusions in initial mode" do
      # Create a session (initial mode)
      assert {:ok, session} = Session.create("TransclusionSession")

      # Read the full document and edit it
      original_content = File.read!(session.path)

      # Manually edit to add transclusion
      content_with_transclusion =
        String.replace(
          original_content,
          "## Request\n\n\n",
          "## Request\n\nTest request with transclusion: \n\n![[Project#Description]]\n\n"
        )

      File.write!(session.path, content_with_transclusion)

      # Reload and assemble
      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Transclusion should be resolved
      assert compiled =~ "This is the project description."
    end
  end

  describe "assemble_all/1 - Continuation Mode" do
    @describetag vault_files: ["concepts/Project.md"]
    setup do
      # Create a session with continuation content (multiple Prompt sections)
      {:ok, session} = Session.create("ContinuationSession")

      # Read the file to get the full document with frontmatter
      original_content = File.read!(session.path)

      # Append the continuation content
      continuation_content =
        original_content <>
          """


          ---

          ***Prompt***

          ---

          ## Follow-up prompt

          This is the second prompt.

          Replace "WRITE_RESPONSE_HERE" with your response in sessions/ContinuationSession.md

          ---

          ***Response***

          ---

          ## Response

          WRITE_RESPONSE_HERE
          """

      File.write!(session.path, continuation_content)

      {:ok, loaded} = Session.load(session.path)
      {:ok, session: loaded}
    end

    test "extracts and compiles only the last Prompt section", %{session: session} do
      # Verify continuation mode
      assert Session.mode(session) == :continuation

      # Assemble should extract only the last Prompt section
      assert {:ok, compiled} = Assembler.assemble_all(session)
      assert is_binary(compiled)

      # Should contain content from the LAST Prompt section only
      assert compiled =~ "This is the second prompt"
      assert compiled =~ "Replace \"WRITE_RESPONSE_HERE\" with your response"

      # Should NOT contain content from initial Request section or Response separators
      refute compiled =~ "***Prompt***"
      refute compiled =~ "***Response***"
    end

    test "resolves transclusions in continuation mode" do
      # Create a session with transclusion in the last Prompt section
      {:ok, session} = Session.create("TransclusionContinuationSession")

      # Read the full document
      original_content = File.read!(session.path)

      continuation_content =
        original_content <>
          """


          ---

          ***Prompt***

          ---

          ## Follow-up prompt

          Here's the project description:

          ![[Project#Description|]]

          Replace "WRITE_RESPONSE_HERE" with your response in sessions/TransclusionContinuationSession.md

          ---

          ***Response***

          ---

          ## Response

          WRITE_RESPONSE_HERE
          """

      File.write!(session.path, continuation_content)

      {:ok, loaded} = Session.load(session.path)

      # Assemble and verify transclusion resolution
      assert {:ok, compiled} = Assembler.assemble_all(loaded)
      assert compiled =~ "Here's the project description:\n\nThis is the project description."
    end
  end
end

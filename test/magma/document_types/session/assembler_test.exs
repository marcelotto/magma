defmodule Magma.Session.AssemblerTest do
  use Magma.Vault.Case, async: false

  alias Magma.Session
  alias Magma.Prompt.Assembler

  describe "assemble_all/1 - Initial Mode" do
    @describetag vault_files: ["plain/Project.md"]
    test "compiles session like a regular Prompt" do
      # Create a new session (initial mode - no Prompt separators)
      assert {:ok, session} = Session.create("InitialModeSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      # Verify it's in initial mode
      assert Session.mode(loaded_session) == :initial

      # Assemble the prompt
      assert {:ok, compiled} = Assembler.assemble_all(loaded_session)
      assert is_binary(compiled)

      # With :external_file mode (default), should contain respond-in-file-rule reference
      assert compiled =~ "respond-in-file-rule"
      assert compiled =~ "CLAUDE.md"
      assert compiled =~ ".responses/InitialModeSession.response_"

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
        Regex.replace(
          ~r/## Request\n+/,
          original_content,
          "## Request\n\nTest request with transclusion:\n\n![[Project#Description]]\n\n"
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
    @describetag vault_files: ["plain/Project.md"]
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

      assert compiled =~
               "Here's the project description:\n\nThis is the project description."
    end
  end

  describe "include_prompt_header configuration" do
    test "initial mode includes header by default" do
      assert {:ok, session} = Session.create("HeaderTest")
      assert {:ok, loaded} = Session.load(session.path)
      assert Session.mode(loaded) == :initial

      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Header should be included by default (config default is true)
      assert compiled =~ "# HeaderTest"
    end

    test "continuation mode excludes header regardless of config" do
      {:ok, session} = Session.create("ContinuationHeaderTest")

      # Add continuation content
      content = File.read!(session.path)

      continuation_content =
        content <>
          """


          ---

          ***Prompt***

          ---

          ## Follow-up prompt

          This is a follow-up.
          """

      File.write!(session.path, continuation_content)

      {:ok, loaded} = Session.load(session.path)
      assert Session.mode(loaded) == :continuation

      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Header should NOT be included for continuations
      refute compiled =~ "# Follow-up prompt"
      # But content should be there
      assert compiled =~ "This is a follow-up."
    end

    test "document-level override disables header" do
      assert {:ok, session} = Session.create("NoHeaderSession")

      # Update frontmatter to disable header
      content = File.read!(session.path)

      # Insert include_prompt_header: false after the opening ---
      updated_content =
        String.replace(
          content,
          "---\nmagma_type:",
          "---\ninclude_prompt_header: false\nmagma_type:",
          global: false
        )

      File.write!(session.path, updated_content)

      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Header should NOT be included when explicitly disabled
      refute compiled =~ "# NoHeaderSession"
    end
  end

  describe "session_response_mode handling" do
    test "auto mode (default) - external file instruction appended by assembler" do
      assert {:ok, session} = Session.create("DefaultMode")
      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Auto mode appends respond-in-file-rule reference with file path (button is present in template)
      assert compiled =~ "respond-in-file-rule"
      assert compiled =~ "CLAUDE.md"
      assert compiled =~ ".responses/DefaultMode.response_"
    end

    test "disabled mode - no response instruction appended" do
      assert {:ok, session} = Session.create("DisabledMode", response_mode: :disabled)
      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      refute compiled =~ "respond-in-file-rule"
    end

    test "enabled mode - response instruction appended by assembler" do
      assert {:ok, session} = Session.create("EnabledMode", response_mode: :enabled)
      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Enabled mode appends instruction via EEx template
      assert compiled =~ "respond-in-file-rule"
      assert compiled =~ "CLAUDE.md"
      assert compiled =~ ".responses/EnabledMode.response_"
    end

    test "auto mode - external file instruction appended by assembler when button present" do
      assert {:ok, session} = Session.create("ImportMode", response_mode: :auto)
      assert {:ok, loaded} = Session.load(session.path)
      assert {:ok, compiled} = Assembler.assemble_all(loaded)

      # Auto mode appends respond-in-file-rule reference with file path (button is present in template)
      assert compiled =~ "respond-in-file-rule"
      assert compiled =~ "CLAUDE.md"
      assert compiled =~ ".responses/ImportMode.response_"
    end

    test "auto mode without button - no response instruction" do
      assert {:ok, session} = Session.create("ImportNoButton", response_mode: :auto)

      # Remove button from content
      content_without_button =
        String.replace(session.content, Magma.Session.Template.import_response_button(), "")

      File.write!(
        session.path,
        Magma.Document.render_front_matter(session) <> content_without_button
      )

      assert {:ok, loaded_session} = Session.load(session.path)

      # Button is not present, so no instruction should be appended
      assert {:ok, assembled} = Assembler.assemble_all(loaded_session)

      refute assembled =~ "respond-in-file-rule"
    end
  end
end

defmodule Magma.SessionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Session

  alias Magma.{Document, Session}

  @tag vault_files: ["concepts/Project.md"]
  test "create/1 and re-load/1 of session" do
    assert {:ok,
            %Session{
              tags: ["magma-vault"],
              aliases: [],
              custom_metadata: %{}
            } = session} = Session.create("Foo")

    assert is_just_now(session.created_at)

    assert session.name == "Foo"
    assert session.path == Vault.path("sessions/#{session.name}.md")

    assert session.content ==
             """
             #{Magma.Prompt.Template.controls(session)}
             ```table-of-contents
             ```
             # #{session.name}

             ## System prompt

             ![[Magma.system.config#Persona|]]

             ### Context knowledge

             The following sections contain background knowledge you need to be aware of.

             ![[Magma.system.config#Context knowledge|]]

             #### Description of the Some project ![[Project#Description|]]


             ## Request



             **Response Instructions:**

             Use the Edit tool to replace the line starting with "WRITE_RESPONSE_HERE" in `test/data/example_vault/sessions/#{session.name}.md`:

             - Pure discussion → Write complete response there (not in chat)
             - Coding task → Complete work first, then write summary there (files changed, decisions made)

             ALWAYS use Edit tool - do NOT output main response in chat.
             Do NOT read the file first - it just contains the conversation we're currently having - use Edit tool directly to replace the marker.


             ---

             ***Response***

             ---

             ## Response

             WRITE_RESPONSE_HERE
             """

    # Load and verify - parts will be parsed during load
    assert {:ok, loaded_session} = Session.load(session.path)
    assert loaded_session.name == session.name
    assert loaded_session.content == session.content
    assert is_list(loaded_session.parts)
    assert [{:initial, _}, {:response, _}] = loaded_session.parts
  end

  test "new/1 initializes document structure" do
    assert {:ok, %Session{name: "MySession"} = session} = Session.new("MySession")
    assert session.path == Vault.path("sessions/MySession.md")
    assert session.name == "MySession"
  end

  test "new!/1 raises on error" do
    # This would only raise if there's an error in path building
    assert %Session{} = Session.new!("ValidSession")
  end

  describe "mode detection" do
    @tag vault_files: ["concepts/Project.md"]
    test "detects initial mode for newly created session" do
      assert {:ok, session} = Session.create("InitialSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      assert Session.mode(loaded_session) == :initial
    end

    @tag vault_files: ["concepts/Project.md"]
    test "detects continuation mode when Prompt separators are present" do
      assert {:ok, session} = Session.create("ContinuationSession")

      continuation_content =
        session.content <>
          """


          ---

          ***Prompt***

          ---

          Follow-up request here.

          ---

          ***Response***

          ---

          WRITE_RESPONSE_HERE
          """

      File.write!(session.path, Document.render_front_matter(session) <> continuation_content)

      assert {:ok, loaded_session} = Session.load(session.path)
      assert Session.mode(loaded_session) == :continuation
    end
  end

  describe "last_prompt_part/1" do
    @tag vault_files: ["concepts/Project.md"]
    test "returns nil in initial mode" do
      assert {:ok, session} = Session.create("InitialSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      assert Session.last_prompt_part(loaded_session) == nil
    end

    @tag vault_files: ["concepts/Project.md"]
    test "extracts last Prompt section in continuation mode" do
      assert {:ok, session} = Session.create("ContinuationSession")

      continuation_content =
        session.content <>
          """


          ---

          ***Prompt***

          ---

          First follow-up request.

          ---

          ***Response***

          ---

          First response.

          ---

          ***Prompt***

          ---

          Second follow-up request.

          ---

          ***Response***

          ---

          WRITE_RESPONSE_HERE
          """

      File.write!(session.path, Document.render_front_matter(session) <> continuation_content)

      assert {:ok, loaded_session} = Session.load(session.path)

      assert last_prompt = Session.last_prompt_part(loaded_session)
      assert is_list(last_prompt)

      assert Enum.any?(last_prompt, fn
               %Panpipe.AST.Para{} -> true
               _ -> false
             end)
    end
  end

  describe "parts parsing" do
    @tag vault_files: ["concepts/Project.md"]
    test "parses parts when loading session" do
      assert {:ok, session} = Session.create("SessionWithParts")
      assert {:ok, loaded_session} = Session.load(session.path)
      assert [{:initial, _initial}, {:response, _content}] = loaded_session.parts
    end
  end
end

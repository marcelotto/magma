defmodule Magma.SessionTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Session

  alias Magma.{Document, Session}

  test "new/1 initializes document structure" do
    assert {:ok, %Session{name: "MySession"} = session} = Session.new("MySession")
    assert session.path == Vault.path("sessions/MySession.md")
    assert session.name == "MySession"
  end

  test "new!/1 raises on error" do
    # This would only raise if there's an error in path building
    assert %Session{} = Session.new!("ValidSession")
  end

  test "create/1 and re-load/1 of session" do
    assert {:ok,
            %Session{
              tags: [],
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

             ## Context

             ### Knowledge Base

             Read the following documents carefully:

             -

             ## Task




             ----

             ***Response***

             ----
             ## Response

             #{Magma.View.button("Import Response", "magma.session.import_response", color: "blue")}




             ----

             ***Notes***

             ----
             #{Magma.View.button("Copy last prompt to clipboard", "magma.prompt.copy")}
             # Notes

             """

    # Load and verify - parts will be parsed during load
    assert {:ok, loaded_session} = Session.load(session.path)
    assert loaded_session.name == session.name
    assert loaded_session.content == session.content
    assert is_list(loaded_session.parts)
    assert [initial: _, response: _, notes: _] = loaded_session.parts
  end

  test "create with session_response_mode" do
    assert {:ok, session} = Session.create("DefaultSession")
    assert String.contains?(session.content, "Import Response")
    assert String.contains?(session.content, "```button")
    assert String.contains?(session.content, "***Response***")

    assert {:ok, session} = Session.create("AutoSession", response_mode: :auto)
    assert String.contains?(session.content, "Import Response")
    assert String.contains?(session.content, "```button")
    assert String.contains?(session.content, "***Response***")

    assert {:ok, session} = Session.create("EnabledSession", response_mode: :enabled)
    assert String.contains?(session.content, "Import Response")
    assert String.contains?(session.content, "```button")
    assert String.contains?(session.content, "***Response***")

    assert {:ok, session} = Session.create("DisabledSession", response_mode: :disabled)
    refute String.contains?(session.content, "***Response***")
    refute String.contains?(session.content, "Import Response")
  end

  describe "mode detection" do
    test "detects initial mode for newly created session" do
      assert {:ok, session} = Session.create("InitialSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      assert Session.mode(loaded_session) == :initial
    end

    test "detects continuation mode when Prompt separators are present" do
      assert {:ok, session} = Session.create("ContinuationSession")

      File.write!(
        session.path,
        Document.render_front_matter(session) <>
          session.content <>
          """


          ----

          ***Prompt***

          ----

          Follow-up request here.

          ----

          ***Response***

          ----

          WRITE_RESPONSE_HERE
          """
      )

      assert {:ok, loaded_session} = Session.load(session.path)
      assert Session.mode(loaded_session) == :continuation
    end
  end

  test "parts parsing" do
    assert {:ok, session} = Session.create("SessionWithParts")
    assert {:ok, loaded_session} = Session.load(session.path)
    assert [initial: _initial, response: _response, notes: _notes] = loaded_session.parts
  end

  describe "last_prompt_part/1" do
    test "returns nil in initial mode" do
      assert {:ok, session} = Session.create("InitialSession")
      assert {:ok, loaded_session} = Session.load(session.path)

      assert Session.last_prompt_part(loaded_session) == nil
    end

    test "extracts last Prompt section in continuation mode" do
      assert {:ok, session} = Session.create("ContinuationSession")

      continuation_content =
        session.content <>
          """


          ----

          ***Prompt***

          ----

          First follow-up request.

          ----

          ***Response***

          ----

          First response.

          ----

          ***Prompt***

          ----

          Second follow-up request.

          ----

          ***Response***

          ----

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

  describe "import_response/1" do
    test "successfully imports response from external file" do
      assert {:ok, session} = Session.create("ImportTest", response_mode: :auto)

      response_file_path = Vault.session_response_file_path("ImportTest")
      File.write!(response_file_path, "This is the imported response content.")

      assert {:ok, updated_session} = Session.import_response("ImportTest")

      expected_content = """
      #{Magma.Prompt.Template.controls(session)}
      ```table-of-contents
      ```
      # #{session.name}

      ## Context

      ### Knowledge Base

      Read the following documents carefully:

      -

      ## Task




      ----

      ***Response***

      ----
      ## Response

      This is the imported response content.




      ----

      ***Notes***

      ----
      #{Magma.View.button("Copy last prompt to clipboard", "magma.prompt.copy")}
      # Notes

      """

      assert updated_session.content == expected_content

      assert {:ok, reloaded_session} = Session.load("ImportTest")
      assert reloaded_session.content == expected_content

      refute File.exists?(response_file_path)
    end

    test "handles missing response file" do
      assert {:ok, _session} = Session.create("NoResponse", response_mode: :auto)
      assert {:error, :not_found} = Session.import_response("NoResponse")
    end

    test "handles empty response file" do
      assert {:ok, _session} = Session.create("EmptyResponse", response_mode: :auto)

      response_file_path = Vault.session_response_file_path("EmptyResponse")
      File.write!(response_file_path, "")

      assert {:error, _} = Session.import_response("EmptyResponse")

      assert File.exists?(response_file_path)
    end

    test "handles missing button in session" do
      assert {:ok, _session} = Session.create("NoButton", response_mode: :disabled)

      response_file_path = Vault.session_response_file_path("NoButton")
      File.write!(response_file_path, "Response content")

      assert {:error, _} = Session.import_response("NoButton")

      assert File.exists?(response_file_path)
    end

    test "finds latest response file among multiple" do
      assert {:ok, session} = Session.create("MultipleResponses", response_mode: :auto)

      old_timestamp = ~U[2025-01-01 10:00:00Z]
      new_timestamp = ~U[2025-01-11 15:30:00Z]

      old_file = Vault.session_response_file_path("MultipleResponses", old_timestamp)
      new_file = Vault.session_response_file_path("MultipleResponses", new_timestamp)

      File.write!(old_file, "Old response")
      File.write!(new_file, "New response")

      assert {:ok, updated_session} = Session.import_response(session)

      expected_content = """
      #{Magma.Prompt.Template.controls(session)}
      ```table-of-contents
      ```
      # #{session.name}

      ## Context

      ### Knowledge Base

      Read the following documents carefully:

      -

      ## Task




      ----

      ***Response***

      ----
      ## Response

      New response




      ----

      ***Notes***

      ----
      #{Magma.View.button("Copy last prompt to clipboard", "magma.prompt.copy")}
      # Notes

      """

      assert updated_session.content == expected_content

      assert {:ok, reloaded_session} = Session.load("MultipleResponses")
      assert reloaded_session.content == expected_content

      refute File.exists?(new_file)
      assert File.exists?(old_file)

      File.rm!(old_file)
    end
  end

  describe "render_session_response_prompt/1" do
    test "paths are relative to vault parent" do
      assert {:ok, session} = Session.create("PathTest")

      assert Session.Template.render_session_response_prompt(session) =~
               "`example_vault/sessions/.responses/"
    end
  end
end

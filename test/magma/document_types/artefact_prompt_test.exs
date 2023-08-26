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

      assert path == Vault.path("__artefacts__/modules/Nested.Example/moduledoc/#{name}.md")
    end
  end

  describe "create/1" do
    @tag vault_files: "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
    test "moduledoc" do
      module_concept = Some.DocumentWithFrontMatter |> module_concept() |> Concept.load!()
      artefact = Artefacts.ModuleDoc.new!(module_concept)
      prompt = Artefact.Prompt.new!(artefact)

      assert {:ok,
              %Artefact.Prompt{
                artefact: ^artefact,
                name: name,
                tags: ["magma-vault"],
                aliases: [],
                created_at: created_at,
                custom_metadata: %{}
              }} = Artefact.Prompt.create(prompt)

      assert name == "Prompt for #{artefact.name}"
      assert DateTime.diff(DateTime.utc_now(), created_at, :second) <= 2
    end
  end

  describe "messages/1" do
    @describetag vault_files: [
                   "__artefacts__/modules/Some.DocumentWithFrontMatter/moduledoc/Prompt for ModuleDoc of Some.DocumentWithFrontMatter.md",
                   "__concepts__/modules/Some/Some.DocumentWithFrontMatter.md"
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
                 "Generate a moduledoc for `Some.DocumentWithFrontMatter`.\n"
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
                          "Generate a moduledoc for `Some.DocumentWithFrontMatter`.\n"
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
                          "Generate a moduledoc for `Some.DocumentWithFrontMatter`.\n"
                        }
             end) =~ "#{prompt.name} contains subsections which won't be taken into account"
    end
  end
end

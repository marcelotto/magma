defmodule Magma.TextTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Text

  alias Magma.Text
  alias Magma.{Concept, Matter, Artefact}

  describe "create/2" do
    @tag vault_files: ["concepts/Project.md"]
    test "creates concept and artefact prompts" do
      text_name = "Example Guide"
      refute Vault.document_path(text_name)

      assert {:ok, %Concept{} = concept} =
               Text.create(text_name, Matter.Texts.UserGuide)

      assert {:ok, ^concept} = Concept.load(text_name)

      assert {:ok, %Artefact.Prompt{}} =
               Artefact.Prompt.load("Prompt for #{text_name} ToC")
    end
  end
end

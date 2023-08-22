defmodule Magma.Artefact.PromptTest do
  use Magma.TestCase, async: false

  doctest Magma.Artefact.Prompt

  alias Magma.Artefact

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

      assert path ==
               Vault.path(
                 "__artefacts__/modules/Nested.Example/moduledoc/Prompt for ModuleDoc of Nested.Example.md"
               )
    end
  end
end

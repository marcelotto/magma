defmodule Magma.Config.ArtefactTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config.Artefact

  test "load/1" do
    assert {:ok,
            %Magma.Config.Artefact{
              name: "ModuleDoc.config",
              tags: ["magma-config"]
            } = config} = Magma.Config.Artefact.load("ModuleDoc.config")

    assert config.content ==
             """
             # ModuleDoc artefact config

             ## System prompt

             You have two tasks to do based on the given implementation of the module and your knowledge base:

             1. generate the content of the `@doc` strings of the public functions
             2. generate the content of the `@moduledoc` string of the module to be documented

             Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

             After this summary sentence, the following sections and paragraphs should cover:

             - What's the purpose of this module/function?
             - For moduledocs: What are the main function(s) of this module?
             - If possible, an example usage in an "Example" section using an indented code block
             - configuration options (if there are any)
             - everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

             The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

             ```markdown
             ## Function docs

             ### `function/1`

             Summary sentence

             Body

             ## Moduledoc

             Summary sentence

             Body
             ```

             <!--
             You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
             -->


             ## Context knowledge


             ## Task prompt

             Generate documentation for module `<%= concept.name %>` according to its description and code in the knowledge base below.
             """

    assert config.path == Vault.path("magma.config/artefacts/ModuleDoc.config.md")
  end
end

defmodule Magma.MixProject do
  use Mix.Project

  @scm_url "https://github.com/marcelotto/magma"

  @version File.read!("VERSION") |> String.trim()

  def project do
    [
      app: :magma,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),

      # ExVCR
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "Magma",
      docs: docs()
    ]
  end

  defp description do
    """
    An IDE for documentation and prompt development.
    """
  end

  defp package do
    [
      maintainers: ["Marcel Otto"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @scm_url,
        "Changelog" => @scm_url <> "/blob/main/CHANGELOG.md"
      },
      files: ~w[lib priv mix.exs .formatter.exs VERSION *.md]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Magma.Application, []}
    ]
  end

  defp deps do
    [
      {:panpipe, "~> 0.3"},
      {:yaml_front_matter, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:openai, "~> 0.5", optional: true},
      {:clipboard, "~> 0.2"},
      {:exvcr, "~> 0.14", only: [:dev, :test]},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Magma",
      source_url: @scm_url,
      source_ref: "v#{@version}",
      logo: "docs.magma/attachments/logo.png",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      before_closing_head_tag: &before_closing_head_tag/1,
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: [
        Vault: [
          Magma.Vault,
          Magma.Vault.BaseVault
        ],
        Documents: [
          Magma.Document,
          Magma.Prompt,
          Magma.Prompt.Template,
          Magma.PromptResult,
          Magma.Concept,
          Magma.Concept.Template,
          Magma.Artefact.Prompt,
          Magma.Artefact.Version
        ],
        DocumentStruct: [
          Magma.DocumentStruct,
          Magma.DocumentStruct.Section
        ],
        Matter: [
          Magma.Matter,
          Magma.Matter.Module,
          Magma.Matter.Project
        ],
        Artefacts: [
          Magma.Artefact,
          Magma.Artefacts.ModuleDoc,
          Magma.Artefacts.Readme,
          Magma.Artefacts.Article
        ],
        Text: [
          Magma.Text,
          Magma.Text.Preview,
          Magma.Matter.Text,
          Magma.Matter.Text.Section,
          Magma.Matter.Text.Type,
          Magma.Matter.Texts.Generic,
          Magma.Matter.Texts.UserGuide,
          Magma.Artefacts.TableOfContents
        ],
        Generation: [
          Magma.Generation,
          Magma.Generation.OpenAI,
          Magma.Generation.Manual
        ]
      ]
    ]
  end

  def extras() do
    [
      user_guide_page("Introduction to Magma"),
      user_guide_page("Installation and setup"),
      user_guide_page("Transclusion Resolution"),
      user_guide_page("Custom Prompts and Prompt Execution"),
      user_guide_page("Creating and Understanding Magma Artefacts"),
      user_guide_page("Generating Complex Artefacts"),
      user_guide_page("Current Limitations and Roadmap"),
      "LICENSE.txt",
      "CHANGELOG.md"
    ]
  end

  defp user_guide_page(name) do
    "docs.magma/artefacts/final/texts/Magma User Guide/article/Magma User Guide - #{name} (article section).md"
  end

  defp groups_for_extras do
    [
      "User Guide": ~r[docs.magma/artefacts/final/texts/Magma User Guide/article/.?]
    ]
  end

  defp before_closing_head_tag(:html) do
    """
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10.2.3/dist/mermaid.min.js"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function () {
        mermaid.initialize({
          startOnLoad: false,
          theme: document.body.className.includes("dark") ? "dark" : "default"
        });
        let id = 0;
        for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
          const preEl = codeEl.parentElement;
          const graphDefinition = codeEl.textContent;
          const graphEl = document.createElement("div");
          const graphId = "mermaid-graph-" + id++;
          mermaid.render(graphId, graphDefinition).then(({svg, bindFunctions}) => {
            graphEl.innerHTML = svg;
            bindFunctions?.(graphEl);
            preEl.insertAdjacentElement("afterend", graphEl);
            preEl.remove();
          });
        }
      });
    </script>
    """
  end

  defp before_closing_head_tag(:epub), do: ""

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/modules"]
  defp elixirc_paths(_), do: ["lib"]
end

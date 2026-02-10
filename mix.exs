defmodule Magma.MixProject do
  use Mix.Project

  @scm_url "https://github.com/marcelotto/magma"

  @version File.read!("VERSION") |> String.trim()

  def project do
    [
      app: :magma,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "Magma",
      docs: docs(),

      # Releases
      releases: releases()
    ]
  end

  def cli do
    [
      preferred_envs: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
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

  defp releases do
    [
      magma: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_arm: [os: :darwin, cpu: :aarch64]
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Magma.Application, []}
    ]
  end

  defp deps do
    [
      {:panpipe, "~> 0.3.2"},
      {:yaml_elixir, "~> 2.12"},
      {:yaml_front_matter, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:openai, "~> 0.5", optional: true},
      {:clipboard, "~> 0.2"},
      {:burrito, "~> 1.0"},
      {:exvcr, "~> 0.17", only: [:dev, :test]},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Magma",
      source_url: @scm_url,
      source_ref: "v#{@version}",
      logo: "logo.png",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      before_closing_head_tag: &before_closing_head_tag/1,
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: [
        Vault: [
          Magma.Vault,
          Magma.Vault.Discovery,
          Magma.Vault.BaseVault,
          Magma.Vault.Version,
          Magma.Vault.Migration
        ],
        Documents: [
          Magma.Document,
          Magma.Prompt,
          Magma.Prompt.Template,
          Magma.PromptResult,
          Magma.Session,
          Magma.Session.Template,
          Magma.View
        ],
        DocumentStruct: [
          Magma.DocumentStruct,
          Magma.DocumentStruct.Section
        ],
        Generation: [
          Magma.Generation,
          Magma.Generation.OpenAI,
          Magma.Generation.Manual
        ],
        Config: [
          Magma.Config,
          Magma.Config.Document,
          Magma.Config.System
        ],
        CLI: [
          Magma.CLI,
          Magma.CLI.Command,
          Magma.CLI.Command.Init,
          Magma.CLI.Command.CopyPrompt,
          Magma.CLI.Command.ExecPrompt,
          Magma.CLI.Command.ImportSession,
          Magma.CLI.Command.Help,
          Magma.CLI.Command.Version,
          Magma.CLI.IO,
          Magma.CLI.FileOps,
          Magma.CLI.Helper
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

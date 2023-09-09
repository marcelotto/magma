defmodule Magma.MixProject do
  use Mix.Project

  def project do
    [
      app: :magma,
      version: "0.1.0",
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
      ]
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
      {:openai, "~> 0.5"},
      {:exvcr, "~> 0.14", only: [:dev, :test]},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/modules"]
  defp elixirc_paths(_), do: ["lib"]
end

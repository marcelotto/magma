defmodule Magma.MixProject do
  use Mix.Project

  def project do
    [
      app: :magma,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
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
      {:yaml_front_matter, "~> 1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/modules"]
  defp elixirc_paths(_), do: ["lib"]
end

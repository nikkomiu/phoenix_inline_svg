defmodule PhoenixInlineSvg.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phoenix_inline_svg,
      version: "1.3.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      description: description(),
      preferred_cli_env: cli_env(),
      test_coverage: [tool: ExCoveralls],
      docs: [extras: ["README.md"]]
    ]
  end

  def cli_env() do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:floki, "~> 0.24"},
      {:inch_ex, "~> 1.0", only: [:dev, :test]},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.20.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    An inline SVG file renderer for Phoenix Framework. This package
    is designed to make loading SVG based icons into HTML structure
    much easeier in Phoenix Frameowrk.
    """
  end

  defp package do
    [
      maintainers: ["Nikko Miu <nikkoamiu@gmail.com>"],
      licenses: ["MIT"],
      files: ~w(lib mix.exs README.md LICENSE),
      links: %{github: "https://github.com/nikkomiu/phoenix_inline_svg"}
    ]
  end
end

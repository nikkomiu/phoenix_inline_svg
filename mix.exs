defmodule PhoenixInlineSvg.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_inline_svg,
     version: "1.1.2",
     elixir: "~> 1.3",
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
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp deps do
    [{:phoenix, "~> 1.2"},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: [:dev, :test]}]
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
      links: %{github: "https://github.com/nikkomiu/phoenix_inline_svg"}
    ]
  end
end

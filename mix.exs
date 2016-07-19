defmodule PhoenixInlineSvg.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_inline_svg,
     version: "0.2.1",
     elixir: "~> 1.3",
     deps: deps(),
     package: package(),
     description: description(),
     docs: [extras: ["README.md"]]
    ]
  end

  def application do
    []
  end

  defp deps do
    [{:phoenix, "~> 1.2"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
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

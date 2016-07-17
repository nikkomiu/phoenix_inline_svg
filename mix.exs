defmodule PhoenixInlineSvg.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_inline_svg,
     version: "0.1.0",
     elixir: "~> 1.3",
     deps: deps,
     package: [
       contributors: ["Nikko Miu"],
       maintainers: ["Nikko Miu"],
       licenses: ["MIT"],
       links: %{github: "https://github.com/nikkomiu/phoenix_inline_svg"}
     ],
     description: """
     SVG Icon Loader for Phoenix
     """
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:phoenix, "~> 1.2"}]
  end
end

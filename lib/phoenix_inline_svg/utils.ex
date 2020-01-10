defmodule PhoenixInlineSvg.Utils do
  @moduledoc false

  def insert_attrs(html, []), do: html

  def insert_attrs(html, attrs) do
    Enum.reduce(attrs, html, fn {attr, value}, acc ->
      attr =
        attr
        |> to_string
        |> String.replace("_", "-")

      acc
      |> Floki.parse_fragment()
      |> case do
        {:ok, html_tree} ->
          html_tree
          |> Floki.attr("svg", attr, &String.trim("#{&1} #{value}"))
          |> Floki.raw_html()

        {:error, html} ->
          raise("Unable to parse html\n#{html}")
      end
    end)
  end

  def safety_string(html) do
    {:safe, html}
  end

  def insert_generic_funcs(ast, collection) do
    default = config_or_default(:default_collection, "generic")

    if default == collection do
      ast
    end
  end

  def config_or_default(config, default) do
    case Application.fetch_env(:phoenix_inline_svg, config) do
      :error ->
        default

      {:ok, data} ->
        data
    end
  end
end

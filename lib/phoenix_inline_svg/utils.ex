defmodule PhoenixInlineSvg.Utils do
  @moduledoc false

  def insert_attrs(html, []), do: html

  def insert_attrs(html, attrs) do
    Enum.reduce(attrs, html, fn {attr, value}, acc ->
      acc
      |> Floki.attr("svg", to_string(attr), &String.trim("#{&1} #{value}"))
      |> Floki.raw_html()
    end)
  end

  def safety_string(html) do
    {:safe, html}
  end

  def insert_generic_funcs(ast, collection) do
    default =
      config_or_default(:default_collection, "generic")

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

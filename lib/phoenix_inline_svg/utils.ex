defmodule PhoenixInlineSvg.Utils do
  @moduledoc false

  def insert_attrs(html, []), do: html
  def insert_attrs(html, attrs) do
    Enum.reduce(attrs, html, fn({attr, value}, acc) ->
      acc
      |> Floki.attr("svg", to_string(attr), &String.trim("#{&1} #{value}"))
      |> Floki.raw_html
    end)
  end

  def safety_string(html) do
    {:safe, html}
  end

  def insert_generic_funcs(ast, "generic"), do: ast
  def insert_generic_funcs(_ast, _collection), do: nil
end

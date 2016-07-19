defmodule PhoenixInlineSvg.Helpers do
  @moduledoc """
  The module that adds the view helpers to fetch
  and render SVG files into safe HTML.

  In order to get best use out of this this module
  should be imported in the quoted `view` def of the `web/web.ex`.

    def view do
      quote do
        import PhoenixInlineSvg.Helpers
      end
    end
  """

  @doc """
  Sends the contents of the SVG file `name` in the directory.

  Returns a safe HTML string with the contents of the SVG file
  wrapped in an `i` HTML element with classes.

  ## Examples

    Using only the default collection (**generic**):
    ```
    <%= svg_image(@conn, "home") %>
    ```

    Will result in output of:
    ```
    <i class="generic-svgs generic-home-svg">
      <svg>...</svg>
    </i>
    ```

    Expects the SVG to be loaded from:
    ```
    priv/static/svg/
    ```

    Which is configurable through the config option:
    ```
    config :phoenix_inline_svg, dir: "some/other/dir"
    ```

    ---

    Using a collection:
    ```
    <%= svg_image(@conn, "user", "fontawesome") %>
    ```

    Will result in the output:
    ```
    <i class="fontawesome-svgs fontawesome-home-svg">
      <svg>...</svg>
    </i>
    ```

  """
  def svg_image(conn, name, collection \\ nil) do
    coll =
      case collection do
        nil -> config_or_default(:default_collection, "generic")
        c -> c
      end

    "#{coll}/#{name}.svg"
    |> read_svg_file(conn)
    |> wrap_svg(coll, name)
    |> safety_string()
  end

  defp safety_string(html) do
    {:safe, html}
  end

  defp wrap_svg(svg_contents, cat, name) do
    "<i class='#{cat}-svgs #{cat}-#{name}-svg'>#{svg_contents}</i>"
  end

  defp read_svg_file(icon_path, conn) do
    file_path = Path.join([
      Application.app_dir(Phoenix.Controller.endpoint_module(conn).config(:otp_app)),
      config_or_default(:dir, "priv/static/svg/"),
      icon_path
    ])

    case File.read(file_path) do
      {:ok, result} ->
        result
      {:error, _} ->
        config_or_default(:not_found,
          "<svg viewbox='0 0 60 60'><text x='0' y='40' font-size='30' font-weight='bold' font-family='monospace'>Err</text></svg>")
    end
  end

  defp config_or_default(config, default) do
    case Application.fetch_env(:phoenix_inline_svg, config) do
      :error ->
        default
      {:ok, data} ->
        data
    end
  end
end

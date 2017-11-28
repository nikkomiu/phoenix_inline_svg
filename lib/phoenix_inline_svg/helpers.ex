defmodule PhoenixInlineSvg.Helpers do
  @moduledoc """
  The module that adds the view helpers to fetch
  and render SVG files into safe HTML.

  ## New Way

  The preferred way of using this library is to add the helpers to the quoted
  `view` in your `web.ex` file.

  ```elixir
  def view do
    quote do
      use PhoenixInlineSvg.Helpers, otp_app: :phoenix_inline_svg
    end
  end
  ```

  Using the new way you can get svg images using the methods:

    ```elixir
    # Get an image with the default collection
    svg_image("image_name")

    # Get an image with a different collection
    svg_image("image_name", "collection_name")
    ```

  ## Old Way

  As an alternative this module can be imported in the quoted `view` def of the
  `web/web.ex` which will always pull the SVG files from the disk (unless you
  are using a caching class).

    ```
    def view do
      quote do
        import PhoenixInlineSvg.Helpers
      end
    end
    ```

  *Note:* If you are setting a custom directory for the SVG files and are using
  Exrm or Distillery, you will need to ensure that the directory you set is in
  the outputted `lib` directory of your application.

  ## In Both Configurations

  By default SVG files are loaded from:
  ```
  priv/static/svg/
  ```

  The directory where SVG files are loaded from can be configured
  by setting the configuration variable:
  ```
  config :phoenix_inline_svg, dir: "some/other/dir"
  ```

  Where `some/other/dir` is a directory located in the Phoenix
  application directory.
  """

  @doc """
  The using method for the Inline SVG library precompiles the SVG images into
  static function definitions.

  **Note** These will not be able to be changed as the contents of the SVG files
  will be directly loaded into the build of the application.

  If you want to support changing SVGs on the fly without a new deployment, use
  the `import` method instead.

  Using this method requires you to tell the use statement what the name of your
  OTP app is.

  ## Examples

    In the quoted `view` def of the `web/web/ex` you should add:

    ```elixir
    use PhoenixInlineSvg.Helpers, otp_app: :my_app_name
    ```

    This will create pre-built functions:

    ```elixir
    # Default collection
    svg_image("image_name")

    # Named collection
    svg_image("image_name", "collection_name")
    ```
  """
  defmacro __using__([otp_app: app_name]) do
    svgs_path = Application.app_dir(app_name,
        config_or_default(:dir, "priv/static/svg/"))

    case File.ls(svgs_path) do
      {:ok, listed_files} ->
        collection_sets =
          listed_files
          |> Enum.filter(fn(e) -> File.dir?(Path.join(svgs_path, e)) end)
          |> Enum.flat_map(fn(coll) ->
            coll_path =
              svgs_path
              |> Path.join(coll)

            coll_path
            |> File.ls!
            |> Enum.filter(fn(e) -> File.regular?(Path.join(coll_path, e)) end)
            |> Enum.map(fn(e) -> {coll, e} end)
          end)

        Enum.map(collection_sets, fn({collection, name}) ->
          quote do
            def svg_image(unquote(name |> String.split(".") |> List.first),
                unquote(collection)) do
              unquote(
                [svgs_path, collection, name]
                |> Path.join
                |> read_svg_from_path
                |> safety_string
              )
            end
          end
        end)

      _ -> nil
    end
  end

  defmacro __using__(_) do
    raise "You must specifiy an OTP app!"
  end

  @doc """
  Sends the contents of the SVG file `name` in the directory.

  Returns a safe HTML string with the contents of the SVG file
  wrapped in an `i` HTML element with classes.

  ## Examples
    ```
    <%= svg_image(@conn, "home") %>
    ```

    Will result in output of:
    ```
    <i class="generic-svgs generic-home-svg">
      <svg>...</svg>
    </i>
    ```

  """
  def svg_image(conn, name) do
    svg_image(conn, name, config_or_default(:default_collection, "generic"))
  end

  @doc """
  Sends the contents of the SVG file `name` in the directory.

  Returns a safe HTML string with the contents of the SVG file
  wrapped in an `i` HTML element with classes.

  ## Examples

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
  def svg_image(conn, name, collection) do
    "#{collection}/#{name}.svg"
    |> read_svg_file(conn)
    |> safety_string
  end

  defp safety_string(html) do
    {:safe, html}
  end

  defp read_svg_from_path(path) do
    case File.read(path) do
      {:ok, result} ->
        result
      {:error, _} ->
        config_or_default(:not_found,
          "<svg viewbox='0 0 60 60'>" <>
          "<text x='0' y='40' font-size='30' font-weight='bold'" <>
          "font-family='monospace'>Err</text></svg>")
    end
  end

  defp read_svg_file(icon_path, conn) do
    [
      Application.app_dir(Phoenix.Controller.endpoint_module(conn).config(:otp_app)),
      config_or_default(:dir, "priv/static/svg/"),
      icon_path
    ]
    |> Path.join
    |> read_svg_from_path
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

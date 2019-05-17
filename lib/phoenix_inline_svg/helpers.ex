defmodule PhoenixInlineSvg.Helpers do
  @moduledoc """
  The module that adds the view helpers to fetch
  and render SVG files into safe HTML.

  ## New Way

  The preferred way of using this library is to add the helpers to the quoted
  `view` in your `web.ex` file.

      def view do
        quote do
          use PhoenixInlineSvg.Helpers, otp_app: :phoenix_inline_svg
        end
      end

  Using the new way you can get svg images using the methods:

      # Get an image with the default collection
      svg_image("image_name")

      # Get an image with a different collection
      svg_image("image_name", "collection_name")

      # Get an image and append html attributes to svg tag
      svg_image("image_name", class: "elixir-is-awesome", id: "inline-svg")

  ## Old Way

  As an alternative this module can be imported in the quoted `view` def of the
  `web/web.ex` which will always pull the SVG files from the disk (unless you
  are using a caching class).


      def view do
        quote do
          import PhoenixInlineSvg.Helpers
        end
      end

  *Note:* If you are setting a custom directory for the SVG files and are using
  Exrm or Distillery, you will need to ensure that the directory you set is in
  the outputted `lib` directory of your application.

  ## In Both Configurations

  By default SVG files are loaded from:
  priv/static/svg/

  The directory where SVG files are loaded from can be configured
  by setting the configuration variable:

      config :phoenix_inline_svg, dir: "some/other/dir"

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

      use PhoenixInlineSvg.Helpers, otp_app: :my_app_name

  This will create pre-built functions:

      # Default collection

      svg_image("image_name")

      # Named collection
      svg_image("image_name", "collection_name")

  """
  defmacro __using__([otp_app: app_name]) do
    svgs_path = Application.app_dir(app_name,
      config_or_default(:dir, "priv/static/svg/"))

    svgs_path
    |> find_collection_sets
    |> Enum.map(&create_cached_svg_image(&1, svgs_path))
  end

  defmacro __using__(_) do
    raise "You must specifiy an OTP app!"
  end

  @doc """
  Sends the contents of the SVG file `name` in the configured
  directory.

  Returns a safe HTML string with the contents of the SVG file
  using the `default_collection` configuration.
  "generic" value.

  ## Examples
      <%= svg_image(@conn, "home") %>
      <%= svg_image(YourAppWeb.Endpoint, "home") %>

  Will result in the output:
  ```html
  <svg>...</svg>
  ```

  The main function is `svg_image/4`.

  """

  def svg_image(conn_or_endpoint, name) do
    svg_image(conn_or_endpoint, name, config_or_default(:default_collection, "generic"))
  end

  @doc """
  Sends the contents of the SVG file `name` in the directory
  with extra `opts` options.

  Returns a safe HTML string with the contents of the SVG file
  after apply options.

  Available options: `:id, :class`

  ## Examples
      <%= svg_image(@conn, "home", class: "logo", id: "bounce-animation") %>
      <%= svg_image(YourAppWeb.Endpoint, "home", class: "logo", id: "bounce-animation") %>

  Will result in the output:

  ```html
  <svg class="logo" id="bounce-animation">...</svg>
  ```

  The main function is `svg_image/4`.

  """
  def svg_image(conn_or_endpoint, name, opts) when is_list(opts) do
    svg_image(conn_or_endpoint, name, config_or_default(:default_collection, "generic"), opts)
  end

  @doc """
  Sends the contents of the SVG file `name` in the `context`
  directory with extra `opts` options.

  Returns a safe HTML string with the contents of the SVG file
  using the `default_collection` configuration.
  `generic` value after apply options.

  ## Examples
  Find SVG file inside of "fontawesome" folder

      <%= svg_image(@conn, "user", "fontawesome") %>
      <%= svg_image(YourAppWeb.Endpoint, "user", "fontawesome") %>

  Will result in the output:
  ```html
  <svg>...</svg>
  ```

  Find SVG file inside of "icons" folder and add
  class "fa fa-share" and id "bounce-animation"

      <%= svg_image(@conn, "user", "icons", class: "fa fa-share", id: "bounce-animation") %>
      <%= svg_image(YourAppWeb.Endpoint, "user", "icons", class: "fa fa-share", id: "bounce-animation") %>

  Will result in the output:
  ```html
  <svg class="fa fa-share" id="bounce-animation">...</svg>
  ```

  """

  def svg_image(conn_or_endpoint, name, collection, opts \\ []) do
    "#{collection}/#{name}.svg"
    |> read_svg_file(conn_or_endpoint)
    |> apply_opts(opts)
    |> safety_string
  end

  defp apply_opts(html, []), do: html
  defp apply_opts(html, opts) do
    Enum.reduce(opts, html, fn({opt, value}, acc) ->
      acc
      |> Floki.attr("svg", to_string(opt), &String.trim("#{&1} #{value}"))
      |> Floki.raw_html
    end)
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

  defp read_svg_file(icon_path, %Plug.Conn{} = conn) do
    [
      Application.app_dir(Phoenix.Controller.endpoint_module(conn).config(:otp_app)),
      config_or_default(:dir, "priv/static/svg/"),
      icon_path
    ]
    |> Path.join
    |> read_svg_from_path
  end

  defp read_svg_file(icon_path, endpoint) do
    [
      Application.app_dir(endpoint.config(:otp_app)),
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

  defp find_collection_sets(svgs_path) do
    case File.ls(svgs_path) do
      {:ok, listed_files} ->
        listed_files
        |> Stream.filter(fn(e) -> File.dir?(Path.join(svgs_path, e)) end)
        |> Stream.flat_map(&map_collection(&1, svgs_path))
        |> Enum.into([])
      _ -> []
    end
  end

  defp map_collection(coll, svgs_path) do
    coll_path = Path.join(svgs_path, coll)

    coll_path
    |> File.ls!
    |> Stream.map(&Path.join(coll_path, &1))
    |> Stream.filter(&File.regular?(&1))
    |> Stream.map(fn(e) -> {coll, e} end)
    |> Enum.into([])
  end

  defp create_cached_svg_image({collection, name}, svgs_path) do
    filename = name |> String.split(".") |> List.first

    quote do
      def svg_image(unquote(filename), unquote(collection)) do
        unquote(
          [svgs_path, collection, name]
          |> Path.join
          |> read_svg_from_path
          |> safety_string
        )
      end
    end
  end
end

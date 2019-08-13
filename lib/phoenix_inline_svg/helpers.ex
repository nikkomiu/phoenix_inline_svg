defmodule PhoenixInlineSvg.Helpers do
  @moduledoc """
  This module adds view helpers for rendering SVG files into safe HTML.

  To add the helpers, add the following to the quoted `view` in your `my_app_web.ex` file.

      def view do
        quote do
          use PhoenixInlineSvg.Helpers
        end
      end

  This will generate functions for each of your images, effectively caching them at compile time.

  You can call these functions like so

      # Get an image with the default collection
      svg_image("image_name")

      # Get an image and insert HTML attributes to svg tag
      svg_image("image_name", class: "elixir-is-awesome", id: "inline-svg")

      # Get an image from a different collection
      svg_image("image_name", "collection_name")

      # Get an image from a different collection and insert HTML attributes to the svg tag
      svg_image("image_name", "collection_name", class: "elixir-is-awesome", id: "inline-svg")


  ## Old Way

  As an alternative this module can be imported in the quoted `view` def of the `my_app_web.ex` which will always pull the SVG files from the disk (unless you are using a caching module).


      def view do
        quote do
          import PhoenixInlineSvg.Helpers
        end
      end

  *Note:* If you are setting a custom directory for the SVG files and are using Exrm or Distillery, you will need to ensure that the directory you set is in the outputted `lib` directory of your application.

  ## Configuration

  By default SVG files are loaded from: assets/static/svg/

  The directory where SVG files are loaded from can be configured by setting the configuration variable:

      config :phoenix_inline_svg, dir: "some/other/dir"

  Where `some/other/dir` is a directory located in the Phoenix application directory.
  """

  @doc """
  The using macro precompiles the SVG images into functions.

  ## Examples

      # Default collection

      svg_image("image_name")
      svg_image("image_name", attrs)

      # Named collection

      svg_image("image_name", "collection_name")
      svg_image("image_name", "collection_name", attrs)

  """
  defmacro __using__(_) do
    svgs_path = PhoenixInlineSvg.Utils.config_or_default(:dir, "assets/static/svg/")

    svgs_path
    |> find_collection_sets
    |> Enum.uniq
    |> Enum.map(&create_cached_svg_image(&1))
  end

  @doc """
  Returns a safe HTML string with the contents of the SVG file using the `default_collection` configuration.

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
    svg_image(conn_or_endpoint, name, PhoenixInlineSvg.Utils.config_or_default(:default_collection, "generic"))
  end

  @doc """
  Returns a safe HTML string with the contents of the SVG file after inserting the given HTML attributes.

  ## Examples

      <%= svg_image(@conn, "home", class: "logo", id: "bounce-animation") %>
      <%= svg_image(YourAppWeb.Endpoint, "home", class: "logo", id: "bounce-animation") %>

  Will result in the output:

  ```html
  <svg class="logo" id="bounce-animation">...</svg>
  ```

  The main function is `svg_image/4`.

  """
  def svg_image(conn_or_endpoint, name, attrs) when is_list(attrs) do
    svg_image(conn_or_endpoint, name, PhoenixInlineSvg.Utils.config_or_default(:default_collection, "generic"), attrs)
  end

  @doc """
  Returns a safe HTML string with the contents of the SVG file for the given collection after inserting the given HTML attributes.

  ## Examples

      <%= svg_image(@conn, "user", "fontawesome") %>
      <%= svg_image(YourAppWeb.Endpoint, "user", "fontawesome") %>

  Will result in the output:
  ```html
  <svg>...</svg>
  ```

  Find SVG file inside of "icons" folder and add class "fa fa-share" and id "bounce-animation"

      <%= svg_image(@conn, "user", "icons", class: "fa fa-share", id: "bounce-animation") %>
      <%= svg_image(YourAppWeb.Endpoint, "user", "icons", class: "fa fa-share", id: "bounce-animation") %>

  Will result in the output:
  ```html
  <svg class="fa fa-share" id="bounce-animation">...</svg>
  ```

  """

  def svg_image(conn_or_endpoint, name, collection, attrs \\ []) do
    "#{collection}/#{name}.svg"
    |> read_svg_file(conn_or_endpoint)
    |> PhoenixInlineSvg.Utils.insert_attrs(attrs)
    |> PhoenixInlineSvg.Utils.safety_string
  end

  defp read_svg_from_path(path) do
    case File.read(path) do
      {:ok, result} ->
        String.trim(result)
      {:error, _} ->
        PhoenixInlineSvg.Utils.config_or_default(:not_found,
          "<svg viewbox='0 0 60 60'>" <>
          "<text x='0' y='40' font-size='30' font-weight='bold'" <>
          "font-family='monospace'>Err</text></svg>")
    end
  end

  defp read_svg_file(icon_path, %Plug.Conn{} = conn) do
    [
      Application.app_dir(Phoenix.Controller.endpoint_module(conn).config(:otp_app)),
      PhoenixInlineSvg.Utils.config_or_default(:dir, "priv/static/svg/"),
      icon_path
    ]
    |> Path.join
    |> read_svg_from_path
  end

  defp read_svg_file(icon_path, endpoint) do
    [
      Application.app_dir(endpoint.config(:otp_app)),
      PhoenixInlineSvg.Utils.config_or_default(:dir, "priv/static/svg/"),
      icon_path
    ]
    |> Path.join
    |> read_svg_from_path
  end


  defp find_collection_sets(svgs_path) do
    case File.ls(svgs_path) do
      {:ok, listed_files} ->
        listed_files
        |> Stream.filter(fn(e) -> File.dir?(Path.join(svgs_path, e)) end)
        |> Enum.flat_map(&map_collection(&1, svgs_path))
      _ ->
        []
    end
  end

  defp map_collection(collection, svgs_path) do
    collection_path =
      Path.join(svgs_path, collection)

    collection_path
    |> File.ls!
    |> Stream.map(&Path.join(collection_path, &1))
    |> Stream.flat_map(&to_file_path/1)
    |> Enum.map(&{collection, &1})
  end

  defp to_file_path(path)do
    if File.dir?(path) do
      path
      |> File.ls!
      |> Stream.map(&Path.join(path, &1))
      |> Enum.flat_map(&to_file_path/1)
    else
      [path]
    end
  end

  defp create_cached_svg_image({collection, name}) do
    try do
      filename =
        hd Regex.run(~r|.*/#{collection}/(.*)\.svg$|, name, capture: :all_but_first)

      svg = read_svg_from_path(name)

      generic_funcs = quote do
        def svg_image(unquote(filename)) do
          svg_image(unquote(filename), unquote(collection), [])
        end

        def svg_image(unquote(filename), opts) when is_list(opts) do
          svg_image(unquote(filename), unquote(collection), opts)
        end
      end

      explicit_funcs = quote do
        def svg_image(unquote(filename), unquote(collection)) do
          svg_image(unquote(filename), unquote(collection), [])
        end

        def svg_image(unquote(filename), unquote(collection), opts) do
          unquote(svg)
          |> PhoenixInlineSvg.Utils.insert_attrs(opts)
          |> PhoenixInlineSvg.Utils.safety_string
        end
      end

      [PhoenixInlineSvg.Utils.insert_generic_funcs(generic_funcs, collection), explicit_funcs]
    rescue
      ArgumentError -> nil
    end
  end
end

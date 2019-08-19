# Phoenix Inline SVG

[![Build Status](https://travis-ci.org/nikkomiu/phoenix_inline_svg.svg?branch=master)](https://travis-ci.org/nikkomiu/phoenix_inline_svg)
[![Coverage Status](https://coveralls.io/repos/github/nikkomiu/phoenix_inline_svg/badge.svg?branch=master)](https://coveralls.io/github/nikkomiu/phoenix_inline_svg?branch=master)
[![Inline docs](http://inch-ci.org/github/nikkomiu/phoenix_inline_svg.svg)](http://inch-ci.org/github/nikkomiu/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/dt/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/v/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/l/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)

Adds support for inline SVG files in Phoenix Framework. This package
allows you to quickly and easily add SVG files into your HTML templates in Phoenix Framework.

## Installation

Add `phoenix_inline_svg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:phoenix_inline_svg, "~> 1.3"}]
end
```

## Usage

```elixir
def view do
  quote do
    ...
    use PhoenixInlineSvg.Helpers
    ...
  end
end
```

### Generic Collection

```elixir
<%= svg_image("home") %>
```

Where `home` is the name of the SVG file you want to load.

This will output the HTML:

```html
<svg>...</svg>
```

By default this will load the SVG file from:

```
/assets/static/svg/generic/home.svg
```

### Collections

There is an optional argument in the function to allow for breaking up SVG files into collections (or folders on the filesystem):

```
<%= svg_image("user", "fontawesome") %>
```

Will result in the output:

```html
<svg>...</svg>
```

This will load the SVG file from:

```
/assets/static/svg/fontawesome/user.svg
```

### HTML attributes

You can also pass optional HTML attributes into the function to set
those properties on the SVG.

```
<%= svg_image("home", class: "logo", id: "bounce-animation") %>
```

Will result in the output:

```html
<svg class="logo" id="bounce-animation">...</svg>
```


## Configuration Options

There are several _optional_ configuration settings for adjusting this package to your needs:

### Directory

The directory in the project from which to load image assets.

If you are using Exrm/Distillery, make sure you use a directory that is outputted to the projects `lib` directory after the release has been created.

```elixir
# If you are using the standard way
config :phoenix_inline_svg, dir: "./assets/somewhere/"

# If you are using the old way
config :phoenix_inline_svg, dir: "/priv/somewhere/"
```

The default value is `/assets/static/svg/` for the standard method and `/priv/static/svg` for the old method.

### Default Collection

The name of the collection to use by default. This is usually overridden to be the primary collection of images.

```elixir
config :phoenix_inline_svg, default_collection: "fontawesome"
```

The default value is `generic`

### Not Found

What should be dispayed in the `<i>` element when there is no SVG file found.

```elixir
config :phoenix_inline_svg, not_found: "<p>Oh No!</p>"
```

The default value is:

```
<svg viewbox='0 0 60 60'>
  <text x='0' y='40' font-size='30' font-weight='bold'
    font-family='monospace'>Err</text>
</svg>
```

## Old Style

To use this package in the old style, add the following line to the view function in your `my_app_web.ex` file.

```elixir
def view do
  quote do
    ...
    import PhoenixInlineSvg.Helpers
    ...
  end
end
```

### Caching SVGs

Since the old style will read the images from disk on every request, you can enable caching through a GenServer.

**For Use with Import Only**: If you use the new style, `use PhoenixInlineSvg.Helpers`, your images are already cached since they are loaded into functions at compile time.


Add the following code to the file `lib/__MY_APP_NAME__/inline_svg_cache.ex`.

**Note**: Be sure to change **\_\_MY_APP_NAME\_\_** to the name of your app.

```elixir
defmodule __MY_APP_NAME__.InlineSvgCache do
  use GenServer

  alias PhoenixInlineSvg.Helpers

  #
  # Client API
  #

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def svg_image(conn, svg, collection \\ nil) do
    svg_name = "#{collection}/#{svg}"
    case lookup(svg_name) do
      {:ok, data} ->
        data
      {:error} ->
        data =
          if collection != nil do
            Helpers.svg_image(conn, svg, collection)
          else
            Helpers.svg_image(conn, svg)
          end
        insert(svg_name, data)
        data
    end
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def insert(name, data) do
    GenServer.cast(__MODULE__, {:insert, name, data})
  end

  #
  # Server API
  #

  def init(_) do
    :ets.new(:svg_image, [:named_table, read_concurrency: true])
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, state) do
    data =
      case :ets.lookup(:svg_image, name) do
        [{^name, data}] -> {:ok, data}
        [] -> {:error}
      end
    {:reply, data, state}
  end

  def handle_cast({:insert, name, data}, state) do
    :ets.insert(:svg_image, {name, data})
    {:noreply, state}
  end
end
```

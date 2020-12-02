# Phoenix Inline SVG

[![Build Status](https://travis-ci.org/nikkomiu/phoenix_inline_svg.svg?branch=master)](https://travis-ci.org/nikkomiu/phoenix_inline_svg)
[![Coverage Status](https://coveralls.io/repos/github/nikkomiu/phoenix_inline_svg/badge.svg?branch=master)](https://coveralls.io/github/nikkomiu/phoenix_inline_svg?branch=master)
[![Inline docs](http://inch-ci.org/github/nikkomiu/phoenix_inline_svg.svg)](http://inch-ci.org/github/nikkomiu/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/dt/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/v/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)
[![Hex.pm](https://img.shields.io/hexpm/l/phoenix_inline_svg.svg)](https://hex.pm/packages/phoenix_inline_svg)

An inline SVG file renderer for Phoenix Framework.

This package is designed to make loading SVG based icons into HTML structure much easeier in PhoenixFrameowrk.

## Installation

Add `phoenix_inline_svg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:phoenix_inline_svg, "~> 1.4"}]
end
```

## Import Helpers

`my_app_web.ex`:

```elixir
def view do
  quote do
    # ...
    use PhoenixInlineSvg.Helpers
    # ...
  end
end
```

## Usage

### load SVG file from default collection

```eex
<%= svg_image("home") %>
```

It will load the SVG file from `/assets/static/svg/generic/home.svg`, and inject the content of SVG file to HTML:
```html
<svg>...</svg>
```

### load SVG file from other collections

You can break up SVG files into collections, and use the second argument of `svg_image/2` to specify the name of collection:

```eex
<%= svg_image("user", "fontawesome") %>
```

It will load the SVG file from `/assets/static/svg/fontawesome/user.svg`, and inject the content of SVG file to HTML:

```html
<svg>...</svg>
```

### HTML attributes

You can also pass optional HTML attributes into the function to set those properties on the SVG:

```eex
<%= svg_image("home", class: "logo", id: "bounce-animation") %>
```

It will output:

```html
<svg class="logo" id="bounce-animation">...</svg>
```

## Configuration Options

There are several optional configuration settings for adjusting this package to your needs:

### `:dir`

Specify the directory from which to load SVG files.

> + the default value for standard way is `/assets/static/svg/`
> + the default value for old way is `/priv/static/svg/`

```elixir
# If you are using the standard way
config :phoenix_inline_svg, dir: "./assets/somewhere/"

# If you are using the old way
config :phoenix_inline_svg, dir: "/priv/somewhere/"
```

> [NOTE] If you are using Exrm/Distillery, make sure you use a directory that is outputted to the projects `lib` directory after the release has been created.

### `:default_collection`

Specify the default collection to use.

> the deafult value is `generic`

```elixir
config :phoenix_inline_svg, default_collection: "fontawesome"
```

### `:not_found`

Specify content to displayed in the `<i>` element when there is no SVG file found.

> the default value is:
> ```
> <svg viewbox='0 0 60 60'>
>   <text x='0' y='40' font-size='30' font-weight='bold'
>     font-family='monospace'>Err</text>
> </svg>
> ```


```elixir
config :phoenix_inline_svg, not_found: "<p>Oh No!</p>"
```

## Old Way

To use this package in the old way, add the following line to the view function in your `my_app_web.ex` file.

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

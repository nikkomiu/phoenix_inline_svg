# Phoenix Inline SVG

Adds support for inline SVG files in Phoenix Framework. This package
allows you to quickly and easily add SVG files into your HTML templates in Phoenix Framework.

## Installation

Add `phoenix_inline_svg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:phoenix_inline_svg, "~> 0.2"}]
end
```

To make using this package easier add the helpers for this
package as an import to your `web.ex` under the view quote:

```elixir
def view do
  quote do
    ...
    import PhoenixInlineSvg.Helpers
    ...
  end
end
```

## Usage

### Generic Collection

If you have set up the import in the `web.ex` file a view can use
this module by adding:

```
<%= svg_image(@conn, "home") %>
```

Where `home` is the name of the SVG file you want to load.
This will output the HTML:

```
<i class="generic-svgs generic-home-svg">
  <svg>...</svg>
</i>
```

By default this will load the SVG file from:

```
/priv/static/svg/generic/home.svg
```

### Collections

There is an optional argument in the function to allow for breaking up
SVG files into collections (or folders on the filesystem):

```
<%= svg_image(@conn, "user", "fontawesome") %>
```

```
<i class="fontawesome-svgs fontawesome-home-svg">
  <svg>...</svg>
</i>
```

This will load the SVG file from:

```
/priv/static/svg/fontawesome/user.svg
```

## Configuration Options

There are several _optional_ configuration settings for adjusting
this package to your needs:

- `dir`: The directory in the project to load image assets from.
    When using this option make sure you use a directory that is
    outputted to a location that is accessible after a release is
    created for the project. (default: `/priv/static/svg/`)
- `default_collection`: The name of the collection to use by default.
    This is usually overridden to be the primary collection of images.
    (default: `generic`)
- `not_found`: What should be dispayed in the `<i>` when there is
    no SVG file found. Default:
    ```
<svg viewbox='0 0 60 60'>
  <text x='0' y='40' font-size='30' font-weight='bold'
    font-family='monospace'>Err</text>
</svg>
```

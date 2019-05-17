defmodule PhoenixInlineSvg.HelpersTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised!(TestApp.Endpoint)

    :ok
  end

  describe "svg_image/2" do
    test "renders an svg" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg")

      assert actual == {:safe, "<svg></svg>\n"}
    end
  end

  describe "svg_image/3" do
    test "renders an svg with an html class" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", class: "fill-current")

      assert actual == {:safe, ~s|<svg class="fill-current"></svg>|}
    end

    test "renders an svg with an html class appended to an existing class" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_with_class_svg", class: "fill-current")

      assert actual == {:safe, ~s|<svg class="existing-class fill-current"></svg>|}
    end

    test "renders an svg with an html id" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", id: "the-image")

      assert actual == {:safe, ~s|<svg id="the-image"></svg>|}
    end

    test "renders an svg with an html class and id" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", class: "fill-current", id: "the-image")

      assert actual == {:safe, ~s|<svg id="the-image" class="fill-current"></svg>|}
    end

    test "renders an svg with an arbitrary attribute" do
      attr = Enum.random(["alice", "bob", "carol"])

      opts = [{attr, "value"}]

      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", opts)

      assert actual == {:safe, ~s|<svg #{attr}="value"></svg>|}
    end
  end
end

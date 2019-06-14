defmodule PhoenixInlineSvg.HelpersTest do
  use ExUnit.Case, async: true
  use PhoenixInlineSvg.Helpers

  setup do
    start_supervised!(TestApp.Endpoint)

    :ok
  end

  describe "static svg_image/2" do
    test "renders an svg" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg")

      assert actual == {:safe, "<svg></svg>"}
    end
  end

  describe "static svg_image/3" do
    test "renders an svg with an html class" do
      actual =
        PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", class: "fill-current")

      assert actual == {:safe, ~s|<svg class="fill-current"></svg>|}
    end

    test "converts multi word attrs from snake case to kebab case" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", aria_labelledby: "me")

      assert actual == {:safe, ~s|<svg aria-labelledby="me"></svg>|}
    end

    test "renders an svg with an html class appended to an existing class" do
      actual =
        PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_with_class_svg",
          class: "fill-current"
        )

      assert actual == {:safe, ~s|<svg class="existing-class fill-current"></svg>|}
    end

    test "renders an svg with an html id" do
      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", id: "the-image")

      assert actual == {:safe, ~s|<svg id="the-image"></svg>|}
    end

    test "renders an svg with an html class and id" do
      actual =
        PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg",
          class: "fill-current",
          id: "the-image"
        )

      assert actual == {:safe, ~s|<svg id="the-image" class="fill-current"></svg>|}
    end

    test "renders an svg with an arbitrary attribute" do
      attr = Enum.random(["alice", "bob", "carol"])

      opts = [{attr, "value"}]

      actual = PhoenixInlineSvg.Helpers.svg_image(TestApp.Endpoint, "test_svg", opts)

      assert actual == {:safe, ~s|<svg #{attr}="value"></svg>|}
    end
  end

  describe "dynamic svg_image/1" do
    test "renders an svg from a generated function" do
      actual = svg_image("test_svg_macro")

      assert actual == {:safe, ~s|<svg></svg>|}
    end

    test "doesn't generate 1 arity functions for custom collections" do
      assert_raise FunctionClauseError, fn -> svg_image("custom_collection") end
    end

    test "renders svg from subdir" do
      actual = svg_image("sub_dir/in_sub_dir_macro")

      assert actual == {:safe, ~s|<svg id="in-sub-dir"></svg>|}
    end
  end

  describe "dynamic svg_image/2" do
    test "renders an svg from a generated function that takes a list of attributes" do
      actual = svg_image("test_svg_macro", class: "fill-current")

      assert actual == {:safe, ~s|<svg class="fill-current"></svg>|}
    end

    test "renders an svg from a generated function that is from a different collection" do
      actual = svg_image("custom_collection_macro", "custom")

      assert actual == {:safe, ~s|<svg id="custom"></svg>|}
    end

    test "doesn't generate 2 arity functions for custom collections" do
      assert_raise FunctionClauseError, fn ->
        svg_image("custom_collection_macro", class: "fill-current")
      end
    end

    test "renders an svg from subdir" do
      actual = svg_image("sub_dir/in_sub_dir_macro", "custom")

      assert actual == {:safe, ~s|<svg id="in-custom-collection-sub-dir"></svg>|}
    end
  end

  describe "dynamic svg_image/3" do
    test "renders an svg from a generated function that is from a different collection and has opts" do
      actual = svg_image("custom_collection_macro", "custom", class: "fill-current")

      assert actual == {:safe, ~s|<svg class="fill-current" id="custom"></svg>|}
    end
  end
end

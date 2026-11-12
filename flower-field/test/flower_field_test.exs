defmodule FlowerFieldTest do
  use ExUnit.Case

  test "multiple empty rows" do
    assert FlowerField.annotate(["", ""]) == ["", ""]
  end

  test "no rows" do
    input = []
    expected = []

    assert FlowerField.annotate(input) == expected
  end

  test "no columns" do
    input = [""]
    expected = [""]

    assert FlowerField.annotate(input) == expected
  end

  test "no flowers" do
    input = [
      "   ",
      "   ",
      "   "
    ]

    expected = [
      "   ",
      "   ",
      "   "
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "flowers only" do
    input = [
      "***",
      "***",
      "***"
    ]

    expected = [
      "***",
      "***",
      "***"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "flower surrounded by spaces" do
    input = [
      "   ",
      " * ",
      "   "
    ]

    expected = [
      "111",
      "1*1",
      "111"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "space surrounded by flowers" do
    input = [
      "***",
      "* *",
      "***"
    ]

    expected = [
      "***",
      "*8*",
      "***"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "horizontal line" do
    input = [
      " * * "
    ]

    expected = [
      "1*2*1"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "horizontal line, flowers at edges" do
    input = [
      "*   *"
    ]

    expected = [
      "*1 1*"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "vertical line" do
    input = [
      " ",
      "*",
      " ",
      "*",
      " "
    ]

    expected = [
      "1",
      "*",
      "2",
      "*",
      "1"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "vertical line, flowers at edges" do
    input = [
      "*",
      " ",
      " ",
      " ",
      "*"
    ]

    expected = [
      "*",
      "1",
      " ",
      "1",
      "*"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "cross" do
    input = [
      "  *  ",
      "  *  ",
      "*****",
      "  *  ",
      "  *  "
    ]

    expected = [
      " 2*2 ",
      "25*52",
      "*****",
      "25*52",
      " 2*2 "
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "large garden" do
    input = [
      " *  * ",
      "  *   ",
      "    * ",
      "   * *",
      " *  * ",
      "      "
    ]

    expected = [
      "1*22*1",
      "12*322",
      " 123*2",
      "112*4*",
      "1*22*2",
      "111111"
    ]

    assert FlowerField.annotate(input) == expected
  end

  test "multiple adjacent flowers" do
    input = [" ** "]
    expected = ["1**1"]

    assert FlowerField.annotate(input) == expected
  end
end

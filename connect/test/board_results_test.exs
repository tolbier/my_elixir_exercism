defmodule Connect.BoardResultsTest do
  use ExUnit.Case

  test "an empty list has no winner" do
    assert Connect.result_for([]) == :none
  end

  test "a single empty cell has no winner" do
    assert Connect.result_for(["."]) == :none
  end

  test "a rectangular board with disconnected stones has no winner" do
    assert Connect.result_for(["X.O", "OX."]) == :none
  end

  test "an empty rectangular board has no winner" do
    assert Connect.result_for(["..", "..", ".."]) == :none
  end

  test "trailing empty columns prevent a horizontal win" do
    assert Connect.result_for(["XX.", "..."]) == :none
  end

  test "trailing empty rows prevent a vertical win" do
    assert Connect.result_for(["O.", "O.", ".."]) == :none
  end
end

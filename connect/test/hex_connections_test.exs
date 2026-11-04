defmodule Connect.HexConnectionsTest do
  use ExUnit.Case

  test "X connects horizontally" do
    assert Connect.result_for(["...", "XXX", "..."]) == :X
  end

  test "O connects vertically" do
    assert Connect.result_for([".O.", ".O.", ".O."]) == :O
  end

  test "the upper-right and lower-left diagonal forms a connection" do
    assert Connect.result_for(["..X", ".X.", "X.."]) == :X
    assert Connect.result_for(["..O", ".O.", "O.."]) == :O
  end

  test "the upper-left and lower-right diagonal does not form a connection" do
    assert Connect.result_for(["X..", ".X.", "..X"]) == :none
    assert Connect.result_for(["O..", ".O.", "..O"]) == :none
  end

  test "an opponent stone breaks a connection" do
    assert Connect.result_for(["...", "XOX", "..."]) == :none
    assert Connect.result_for([".O.", ".X.", ".O."]) == :none
  end

  test "an isolated stone does not form a connection" do
    assert Connect.result_for(["...", ".O.", "..."]) == :none
  end
end

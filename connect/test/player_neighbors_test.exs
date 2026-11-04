defmodule Connect.PlayerNeighborsTest do
  use ExUnit.Case

  describe "player_neighbors/3" do
    test "returns all six hexagonal neighbors without including the origin" do
      connect = Connect.parse_board(["XXX", "XXX", "XXX"])

      assert Enum.sort(Connect.player_neighbors(connect, {1, 1}, :X)) ==
               Enum.sort([{0, 1}, {2, 1}, {1, 0}, {2, 0}, {0, 2}, {1, 2}])
    end

    test "filters out empty cells and stones belonging to the other player" do
      connect = Connect.parse_board([".OX", "OXX", "X.X"])

      assert Enum.sort(Connect.player_neighbors(connect, {1, 1}, :X)) ==
               Enum.sort([{2, 0}, {2, 1}, {0, 2}])

      assert Enum.sort(Connect.player_neighbors(connect, {1, 1}, :O)) ==
               Enum.sort([{1, 0}, {0, 1}])
    end

    test "does not treat the upper-left and lower-right cells as neighbors" do
      connect = Connect.parse_board(["X..", ".X.", "..X"])

      assert Connect.player_neighbors(connect, {1, 1}, :X) == []
    end

    test "excludes coordinates outside each corner of a rectangular board" do
      connect = Connect.parse_board(["OOO", "OOO"])

      for {coords, expected} <- [
            {{0, 0}, [{1, 0}, {0, 1}]},
            {{2, 0}, [{1, 0}, {1, 1}, {2, 1}]},
            {{0, 1}, [{0, 0}, {1, 0}, {1, 1}]},
            {{2, 1}, [{2, 0}, {1, 1}]}
          ] do
        assert Enum.sort(Connect.player_neighbors(connect, coords, :O)) == Enum.sort(expected)
      end
    end

    test "a single stone has no neighbors" do
      connect = Connect.parse_board(["X"])

      assert Connect.player_neighbors(connect, {0, 0}, :X) == []
    end

    test "returns an empty list when every adjacent cell is empty" do
      connect = Connect.parse_board(["...", ".O.", "..."])

      assert Connect.player_neighbors(connect, {1, 1}, :O) == []
    end
  end
end

defmodule Connect.StrListToConnectTest do
  use ExUnit.Case

  describe "str_list_to_connect/1" do
    test "an empty list produces an empty board with zero dimensions" do
      assert Connect.str_list_to_connect([]) == %Connect{board: %{}, width: 0, height: 0}
    end

    test "a single cell uses the origin for each cell type" do
      assert Connect.str_list_to_connect(["X"]) ==
               %Connect{board: %{{0, 0} => :X}, width: 1, height: 1}

      assert Connect.str_list_to_connect(["O"]) ==
               %Connect{board: %{{0, 0} => :O}, width: 1, height: 1}

      assert Connect.str_list_to_connect(["."]) ==
               %Connect{board: %{}, width: 1, height: 1}
    end

    test "a rectangular board uses columns for x and rows for y" do
      assert Connect.str_list_to_connect(["X.O", "OX."]) == %Connect{
               board: %{
                 {0, 0} => :X,
                 {2, 0} => :O,
                 {0, 1} => :O,
                 {1, 1} => :X
               },
               width: 3,
               height: 2
             }
    end

    test "empty cells are omitted while board dimensions are preserved" do
      assert Connect.str_list_to_connect(["..", "..", ".."]) == %Connect{
               board: %{},
               width: 2,
               height: 3
             }
    end
  end
end

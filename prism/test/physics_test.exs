defmodule PhysicsTest do
  use ExUnit.Case

  describe "find_collision/5" do
    test "does not hit the prism at the ray's current position" do
      assert Physics.find_collision(10, 10, 10, 10, 45) == :no_collision
    end

    test "hits a diagonal point ahead but not behind the ray" do
      assert {:collision, distance} = Physics.find_collision(10, 10, 0, 0, 45)
      assert_in_delta distance, 14.142135623730951, 1.0e-9
      assert Physics.find_collision(-10, -10, 0, 0, 45) == :no_collision
    end

    test "misses a nearby point outside the rounding tolerance" do
      assert Physics.find_collision(10, 0.1, 0, 0, 0) == :no_collision
    end

    test "hits a prism to the right" do
      assert {:collision, distance} = Physics.find_collision(10, 0, 0, 0, 0)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "misses a prism behind a ray going right" do
      assert Physics.find_collision(-10, 0, 0, 0, 0) == :no_collision
    end

    test "hits a prism above the origin" do
      assert {:collision, distance} = Physics.find_collision(0, 10, 0, 0, 90)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "going up misses prisms behind or beside the ray" do
      for {x, y} <- [{0, -10}, {-10, 0}, {10, 0}] do
        assert Physics.find_collision(x, y, 0, 0, 90) == :no_collision
      end
    end

    test "hits a prism below the origin" do
      assert {:collision, distance} = Physics.find_collision(0, -10, 0, 0, -90)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "going down misses prisms behind or beside the ray" do
      for {x, y} <- [{10, 0}, {0, 10}, {-10, 0}] do
        assert Physics.find_collision(x, y, 0, 0, -90) == :no_collision
      end
    end

    test "hits a prism to the left" do
      assert {:collision, distance} = Physics.find_collision(-10, 0, 0, 0, 180)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "going left misses prisms behind or beside the ray" do
      for {x, y} <- [{0, 10}, {10, 0}, {0, -10}] do
        assert Physics.find_collision(x, y, 0, 0, 180) == :no_collision
      end
    end

    test "accepts a negative angle equivalent to going left" do
      assert {:collision, distance} = Physics.find_collision(-10, 0, 0, 0, -180)
      assert_in_delta distance, 10.0, 1.0e-9

      for {x, y} <- [{0, -10}, {0, 10}, {10, 0}] do
        assert Physics.find_collision(x, y, 0, 0, -180) == :no_collision
      end
    end

    test "accepts an angle larger than a full turn" do
      assert {:collision, distance} = Physics.find_collision(-10, 0, 0, 0, 2340)
      assert_in_delta distance, 10.0, 1.0e-9
      assert Physics.find_collision(10, 0, 0, 0, 2340) == :no_collision
    end

    test "hits a prism after upward refraction from a shifted origin" do
      assert {:collision, distance} = Physics.find_collision(10, 10, 10, 0, 90)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "hits a prism after downward refraction from a shifted origin" do
      assert {:collision, distance} = Physics.find_collision(10, -10, 10, 0, -90)
      assert_in_delta distance, 10.0, 1.0e-9
    end

    test "hits a previous prism when the ray reverses direction" do
      assert {:collision, distance} = Physics.find_collision(10, 0, 20, 0, -180)
      assert_in_delta distance, 10.0, 1.0e-9
      assert Physics.find_collision(10, 0, 20, 0, 0) == :no_collision
    end

    test "hits a prism horizontally from a shifted origin" do
      assert {:collision, distance} = Physics.find_collision(30, 10, 10, 10, 0)
      assert_in_delta distance, 20.0, 1.0e-9
      assert Physics.find_collision(20, 0, 10, 10, 0) == :no_collision
    end

    test "hits the first prism using a rounded floating point angle" do
      assert {:collision, distance} = Physics.find_collision(14.2, -1.6, 0, 0, -6.429)
      assert_in_delta distance, 14.289856542317, 1.0e-9
    end

    test "hits the next prism after adding its refraction angle" do
      assert {:collision, distance} =
               Physics.find_collision(24.0, 0.6, 14.2, -1.6, -6.429 + 19.081)

      assert_in_delta distance, 10.043903623591776, 1.0e-9
    end

    test "hits a prism using a rounded angle from the complex path" do
      assert {:collision, distance} = Physics.find_collision(-0.8, 15.6, 7.0, 0.0, 116.565)
      assert_in_delta distance, 17.44133022449836, 1.0e-9
    end
  end

  describe "closest_collision/2" do
    test "returns no collision for an empty list" do
      assert Physics.closest_collision([], %{angle: 0, x: 0, y: 0}) == :no_collision
    end

    test "returns the only prism when it is hit" do
      prism = %{id: 1, angle: 0, x: 10, y: 0}

      assert Physics.closest_collision([prism], %{angle: 0, x: 0, y: 0}) == prism
    end

    test "returns no collision when the only prism is behind the ray" do
      prism = %{id: 1, angle: 0, x: -10, y: 0}

      assert Physics.closest_collision([prism], %{angle: 0, x: 0, y: 0}) == :no_collision
    end

    test "returns no collision when all prisms miss the ray" do
      prisms = [
        %{id: 3, angle: 0, x: 0, y: -10},
        %{id: 1, angle: 0, x: -10, y: 0},
        %{id: 2, angle: 0, x: 10, y: 0}
      ]

      assert Physics.closest_collision(prisms, %{angle: 90, x: 0, y: 0}) == :no_collision
    end

    test "selects the nearest hit regardless of list order" do
      near = %{id: 2, angle: 0, x: 10, y: 0}
      far = %{id: 2, angle: -180, x: 20, y: 0}
      start = %{angle: 0, x: 0, y: 0}

      assert Physics.closest_collision([far, near], start) == near
      assert Physics.closest_collision([near, far], start) == near
    end

    test "ignores misses even when they are closer than a hit" do
      miss = %{id: 1, angle: 0, x: 0, y: -10}
      hit = %{id: 2, angle: 0, x: 20, y: 0}

      assert Physics.closest_collision([miss, hit], %{angle: 0, x: 0, y: 0}) == hit
    end

    test "measures distance from the current ray origin" do
      near = %{id: 1, angle: 0, x: 20, y: 0}
      far = %{id: 2, angle: 0, x: 10, y: 0}
      start = %{angle: -180, x: 30, y: 0}

      assert Physics.closest_collision([far, near], start) == near
    end

    test "ignores the prism at the ray origin and finds the next hit" do
      current = %{id: 2, angle: 90, x: 10, y: 0}
      next = %{id: 1, angle: -90, x: 10, y: 10}
      start = %{angle: 90, x: 10, y: 0}

      assert Physics.closest_collision([current, next], start) == next
    end

    test "selects a hit using a rounded floating point angle" do
      miss = %{id: 12, angle: 0.0, x: -1.0, y: 0.2}
      hit = %{id: 7, angle: 19.081, x: 14.2, y: -1.6}
      start = %{angle: -6.429, x: 0, y: 0}

      assert Physics.closest_collision([miss, hit], start) == hit
    end
  end
end

defmodule BitMasksTest do
  use ExUnit.Case

  doctest BitMasks

  describe "choose/2" do
    test "chooses 2 positions out of 4" do
      assert BitMasks.choose(4, 2) == [
               [1, 1, 0, 0],
               [1, 0, 1, 0],
               [1, 0, 0, 1],
               [0, 1, 1, 0],
               [0, 1, 0, 1],
               [0, 0, 1, 1]
             ]
    end

    test "choosing 1 position gives one mask per position" do
      assert BitMasks.choose(3, 1) == [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    end

    test "choosing no positions gives a single mask of zeros" do
      assert BitMasks.choose(3, 0) == [[0, 0, 0]]
    end

    test "choosing every position gives a single mask of ones" do
      assert BitMasks.choose(3, 3) == [[1, 1, 1]]
    end

    test "zero digits gives a single empty mask" do
      assert BitMasks.choose(0, 0) == [[]]
    end

    test "choosing more positions than digits gives no masks" do
      assert BitMasks.choose(2, 3) == []
    end

    test "every mask has n digits and exactly k ones, without repetitions" do
      for n <- 0..8, k <- 0..n do
        masks = BitMasks.choose(n, k)

        assert length(masks) == binomial(n, k)
        assert Enum.all?(masks, &(length(&1) == n and Enum.sum(&1) == k))
        assert masks == Enum.uniq(masks)
      end
    end
  end

  describe "non_empty/1" do
    test "all non-empty masks of 3 digits, ordered by number of ones" do
      assert BitMasks.non_empty(3) == [
               [1, 0, 0],
               [0, 1, 0],
               [0, 0, 1],
               [1, 1, 0],
               [1, 0, 1],
               [0, 1, 1],
               [1, 1, 1]
             ]
    end

    test "one digit gives a single mask" do
      assert BitMasks.non_empty(1) == [[1]]
    end

    test "zero digits gives no masks" do
      assert BitMasks.non_empty(0) == []
    end

    test "every non-empty mask appears once, from fewest to most ones" do
      for n <- 0..8 do
        masks = BitMasks.non_empty(n)
        ones = Enum.map(masks, &Enum.sum/1)

        assert length(masks) == Integer.pow(2, n) - 1
        assert Enum.all?(masks, &(length(&1) == n))
        assert Enum.all?(ones, &(&1 >= 1))
        assert masks == Enum.uniq(masks)
        assert ones == Enum.sort(ones)
      end
    end
  end

  describe "apply_mask/2" do
    test "subtracts one copy of each title marked with 1" do
      assert BitMasks.apply_mask([3, 2, 1], [1, 0, 0]) == [2, 2, 1]
    end

    test "drops the titles left without copies" do
      assert BitMasks.apply_mask([2, 1, 1], [0, 1, 0]) == [2, 1]
    end

    test "keeps the counts sorted from most to fewest copies" do
      assert BitMasks.apply_mask([2, 2, 1], [1, 0, 0]) == [2, 1, 1]
    end

    test "a mask of zeros leaves the counts unchanged" do
      assert BitMasks.apply_mask([2, 1], [0, 0]) == [2, 1]
    end

    test "removing the last copy of every title leaves nothing" do
      assert BitMasks.apply_mask([1, 1, 1], [1, 1, 1]) == []
    end
  end

  describe "cost/1" do
    test "group of 1 has no discount" do
      assert BitMasks.cost([1]) == 800
    end

    test "group of 2 has a 5% discount" do
      assert BitMasks.cost([1, 1]) == 1520
    end

    test "group of 3 has a 10% discount" do
      assert BitMasks.cost([1, 1, 1]) == 2160
    end

    test "group of 4 has a 20% discount" do
      assert BitMasks.cost([1, 1, 1, 1]) == 2560
    end

    test "group of 5 has a 25% discount" do
      assert BitMasks.cost([1, 1, 1, 1, 1]) == 3000
    end

    test "only counts a single title marked out of five" do
      assert BitMasks.cost([0, 0, 0, 1, 0]) == 800
    end

    test "only counts three titles marked out of five" do
      assert BitMasks.cost([1, 0, 1, 0, 1]) == 2160
    end

    test "only counts four titles marked out of five" do
      assert BitMasks.cost([1, 1, 0, 1, 1]) == 2560
    end
  end

  # n! / (k! * (n - k)!)
  defp binomial(n, k), do: div(factorial(n), factorial(k) * factorial(n - k))

  defp factorial(n), do: Enum.product(1..n//1)
end

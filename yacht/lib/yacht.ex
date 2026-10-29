defmodule Yacht do
  @moduledoc "Calculates scores for Yacht dice rolls."

  @type category ::
          :ones
          | :twos
          | :threes
          | :fours
          | :fives
          | :sixes
          | :full_house
          | :four_of_a_kind
          | :little_straight
          | :big_straight
          | :choice
          | :yacht

  @doc """
  Calculate the score of 5 dice using the given category's scoring method.
  """
  @spec score(category :: category(), dice :: [integer]) :: integer
  def score(category, dice) do
    do_score(category, Enum.sort(dice))
  end

  @spec do_score(category(), [integer()]) :: integer()
  defp do_score(:yacht, [n, n, n, n, n]), do: 50
  defp do_score(:ones, dice), do: sum_matching(1, dice)
  defp do_score(:twos, dice), do: sum_matching(2, dice)
  defp do_score(:threes, dice), do: sum_matching(3, dice)
  defp do_score(:fours, dice), do: sum_matching(4, dice)
  defp do_score(:fives, dice), do: sum_matching(5, dice)
  defp do_score(:sixes, dice), do: sum_matching(6, dice)
  defp do_score(:full_house, [a, a, a, b, b]) when a != b, do: full_house(a, b)
  defp do_score(:full_house, [a, a, b, b, b]) when a != b, do: full_house(b, a)
  defp do_score(:four_of_a_kind, [a, a, a, a, _]), do: four_of_a_kind(a)
  defp do_score(:four_of_a_kind, [_, a, a, a, a]), do: four_of_a_kind(a)
  defp do_score(:little_straight, [1, 2, 3, 4, 5]), do: 30
  defp do_score(:big_straight, [2, 3, 4, 5, 6]), do: 30
  defp do_score(:choice, dice), do: Enum.sum(dice)
  defp do_score(_, _), do: 0

  @spec sum_matching(integer(), [integer()]) :: integer()
  defp sum_matching(value, dice), do: Enum.count(dice, &(&1 == value)) * value

  @spec full_house(integer(), integer()) :: integer()
  defp full_house(triple, pair), do: triple * 3 + pair * 2

  @spec four_of_a_kind(integer()) :: integer()
  defp four_of_a_kind(value), do: value * 4
end

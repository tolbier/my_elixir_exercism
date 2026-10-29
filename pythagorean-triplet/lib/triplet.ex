defmodule Triplet do
  @moduledoc """
  Find Pythagorean triplets from a given sum.
  """

  @doc """
  Calculates sum of a given triplet of integers.
  """
  @spec sum([non_neg_integer]) :: non_neg_integer
  def sum(triplet), do: Enum.sum(triplet)

  @doc """
  Calculates product of a given triplet of integers.
  """
  @spec product([non_neg_integer]) :: non_neg_integer
  def product(triplet), do: Enum.product(triplet)

  @doc """
  Determines if a given triplet is pythagorean. That is, do the squares of a and b add up to the square of c?
  """
  @spec pythagorean?([non_neg_integer]) :: boolean
  def pythagorean?([a, b, c]), do: a * a + b * b == c * c

  @doc """
  Generates a list of pythagorean triplets whose values add up to a given sum.
  """
  @spec generate(non_neg_integer) :: [list(non_neg_integer)]
  def generate(n) do
    for(
      c <- div(n, 3)..div(n, 2),
      b <- div(n - c, 2)..(c - 1)//1,
      a = n - b - c,
      a > 0,
      a < b,
      candidate = [a, b, c],
      pythagorean?(candidate),
      do: candidate
    )
    |> Enum.sort()
  end
end

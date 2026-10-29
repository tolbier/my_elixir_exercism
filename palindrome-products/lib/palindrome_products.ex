defmodule PalindromeProducts do
  @moduledoc """
  Find the smallest and largest palindrome products within a range of factors.
  """

  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: %{non_neg_integer => [[non_neg_integer]]}
  def generate(max_factor, min_factor \\ 1)

  def generate(max_factor, min_factor) when max_factor < min_factor,
    do: raise(ArgumentError, "min must be <= max")

  def generate(max_factor, min_factor) do
    for i <- min_factor..max_factor,
        j <- i..max_factor,
        key = i * j,
        palindrome?(key),
        reduce: %{} do
      acc -> Map.update(acc, key, [[i, j]], &[[i, j] | &1])
    end
  end

  @spec palindrome?(non_neg_integer) :: boolean
  defp palindrome?(n), do: n == reverse_digits(n)

  @spec reverse_digits(non_neg_integer, non_neg_integer) :: non_neg_integer
  defp reverse_digits(n, acc \\ 0)
  defp reverse_digits(0, acc), do: acc
  defp reverse_digits(n, acc), do: reverse_digits(div(n, 10), acc * 10 + rem(n, 10))
end

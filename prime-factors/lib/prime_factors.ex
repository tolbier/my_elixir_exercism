defmodule PrimeFactors do
  @moduledoc """
  Computes the prime factorization of a number by trial division.
  """

  @doc """
  Compute the prime factors for 'number'.

  The prime factors are prime numbers that when multiplied give the desired
  number.

  The prime factors of 'number' will be ordered lowest to highest.
  """
  @spec factors_for(pos_integer) :: [pos_integer]
  def factors_for(number), do: factor(number) |> Enum.reverse()

  @spec factor(pos_integer, pos_integer, [pos_integer]) :: [pos_integer]
  defp factor(number, divisor \\ 2, acc \\ [])
  defp factor(1, _divisor, acc), do: acc
  defp factor(number, divisor, acc) when divisor * divisor > number, do: [number | acc]

  defp factor(number, divisor, acc) when rem(number, divisor) == 0,
    do: factor(div(number, divisor), divisor, [divisor | acc])

  defp factor(number, divisor, acc), do: factor(number, divisor + 1, acc)
end

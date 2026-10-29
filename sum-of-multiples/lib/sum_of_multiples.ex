defmodule SumOfMultiples do
  @moduledoc """
  Calculates the sum of all multiples of a set of factors below a limit.
  """

  @doc """
  Adds up all numbers from 1 to a given end number that are multiples of the factors provided.
  """
  @spec to(non_neg_integer, [non_neg_integer]) :: non_neg_integer
  def to(limit, factors) do
    factors
    |> Enum.filter(&(&1 > 0))
    |> Enum.map(&stream(&1, limit))
    |> Stream.concat()
    |> Stream.uniq()
    |> Enum.sum()
  end

  @spec stream(pos_integer, non_neg_integer) :: Enumerable.t()
  defp stream(n, limit), do: Stream.iterate(n, &(&1 + n)) |> Stream.take_while(&(&1 < limit))
end

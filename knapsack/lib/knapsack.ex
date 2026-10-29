defmodule Knapsack do
  @moduledoc "Calculates the maximum value a knapsack can carry."

  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(items :: [%{value: integer, weight: integer}], maximum_weight :: integer) ::
          integer
  def maximum_value(items, maximum_weight) do
    do_maximum_value(items, maximum_weight, 0)
  end

  @spec do_maximum_value([%{value: integer, weight: integer}], integer, integer) :: integer
  defp do_maximum_value(_, maximum_weight, _)
       when maximum_weight < 0, do: 0

  defp do_maximum_value([], _, acc), do: acc

  defp do_maximum_value([%{value: value, weight: weight} | rest], maximum_weight, acc) do
    max(
      do_maximum_value(rest, maximum_weight - weight, acc + value),
      do_maximum_value(rest, maximum_weight, acc)
    )
  end
end

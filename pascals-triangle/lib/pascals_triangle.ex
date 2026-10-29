defmodule PascalsTriangle do
  @moduledoc """
  Calculates the rows of Pascal's triangle up to a given height.
  """

  @doc """
  Calculates the rows of a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(n), do: do_rows(n)

  @spec do_rows(non_neg_integer, [integer]) :: [[integer]]
  defp do_rows(n, previous_row \\ [1])
  defp do_rows(1, previous_row), do: [previous_row]

  defp do_rows(n, previous_row),
    do: [previous_row | do_rows(n - 1, next_pascal_row(previous_row))]

  @spec next_pascal_row([integer], integer) :: [integer]
  defp next_pascal_row(list, old \\ 0)
  defp next_pascal_row([], old), do: [old]
  defp next_pascal_row([h | t], old), do: [h + old | next_pascal_row(t, h)]
end

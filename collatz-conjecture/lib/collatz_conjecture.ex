defmodule CollatzConjecture do
  @moduledoc """
  Calculates the number of steps for the Collatz conjecture to reach 1.
  """

  require Integer

  @doc """
  calc/1 takes an integer and returns the number of steps required to get the
  number to 1 when following the rules:
    - if number is odd, multiply with 3 and add 1
    - if number is even, divide by 2
  """
  @spec calc(input :: pos_integer()) :: non_neg_integer()
  def calc(n) when n > 0, do: do_calc(n, 0)

  @spec do_calc(input :: pos_integer(), acc :: non_neg_integer()) :: non_neg_integer()
  defp do_calc(1, acc), do: acc
  defp do_calc(n, acc) when Integer.is_even(n), do: do_calc(div(n, 2), acc + 1)
  defp do_calc(n, acc), do: do_calc(3 * n + 1, acc + 1)
end

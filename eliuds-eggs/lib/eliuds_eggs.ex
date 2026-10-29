defmodule EliudsEggs do
  @moduledoc """
  Counts eggs represented as set bits in a number.
  """

  @doc """
  Given the number, count the number of eggs.
  """
  @spec egg_count(number :: integer()) :: non_neg_integer()
  def egg_count(number) do
    do_egg_count(number, 0)
  end

  @spec do_egg_count(integer(), non_neg_integer()) :: non_neg_integer()
  defp do_egg_count(0, acc), do: acc
  defp do_egg_count(n, acc), do: do_egg_count(div(n, 2), acc + rem(n, 2))
end

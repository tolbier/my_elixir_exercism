defmodule KillerSudokuHelper do
  @moduledoc """
  Lists the valid digit combinations for a Killer Sudoku cage.
  """

  @doc """
  Return the possible combinations of `size` distinct numbers from 1-9 excluding `exclude` that sum up to `sum`.
  """
  @spec combinations(cage :: %{exclude: [integer], size: integer, sum: integer}) :: [[integer]]
  def combinations(cage) do
    subsets(
      1..9
      |> Enum.to_list()
      |> Enum.reject(&(&1 in cage.exclude)),
      cage.size
    )
    |> Enum.filter(&(Enum.sum(&1) == cage.sum))
  end

  @spec subsets([integer()], non_neg_integer()) :: [[integer()]]
  defp subsets(_list, 0), do: [[]]
  defp subsets([], _size), do: []

  defp subsets([head | tail], size) do
    with_head = Enum.map(subsets(tail, size - 1), &[head | &1])
    without_head = subsets(tail, size)

    with_head ++ without_head
  end
end

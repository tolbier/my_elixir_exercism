defmodule Spiral do
  @moduledoc """
  Generates a square matrix filled with numbers in clockwise spiral order.
  """

  @doc """
  Given the dimension, return a square matrix of numbers in clockwise spiral order.
  """
  @spec matrix(dimension :: integer) :: list(list(integer))
  def matrix(n) when n <= 0, do: []

  def matrix(n) do
    matrix(n - 1)
    |> rotate()
    |> sum_to_all_cells()
    |> add_final_cell_to_rows()
    |> add_first_row()
  end

  @spec rotate(list(list(integer))) :: list(list(integer))
  defp rotate(matrix) do
    matrix
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
  end

  @spec sum_to_all_cells(list(list(integer))) :: list(list(integer))
  defp sum_to_all_cells(matrix) do
    n = length(matrix) * 2 + 1

    matrix
    |> Enum.map(fn row ->
      Enum.map(row, &(&1 + n))
    end)
  end

  @spec add_final_cell_to_rows(list(list(integer))) :: list(list(integer))
  defp add_final_cell_to_rows(matrix) do
    matrix
    |> Enum.with_index(length(matrix) + 2)
    |> Enum.map(fn {row, idx} -> row ++ [idx] end)
  end

  @spec add_first_row(list(list(integer))) :: list(list(integer))
  defp add_first_row(matrix) do
    n = length(matrix) + 1
    [Enum.to_list(1..n) | matrix]
  end
end

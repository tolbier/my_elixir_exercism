defmodule SaddlePoints do
  @moduledoc """
  Find saddle points in a matrix given as a string.
  """

  @doc """
  Parses a string representation of a matrix
  to a list of rows
  """
  @spec rows(String.t()) :: [[integer]]
  def rows(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn row_str ->
      row_str |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end)
  end

  @doc """
  Parses a string representation of a matrix
  to a list of columns
  """
  @spec columns(String.t()) :: [[integer]]
  def columns(str) do
    str
    |> rows()
    |> columns_from_rows()
  end

  @doc """
  Calculates all the saddle points from a string
  representation of a matrix
  """
  @spec saddle_points(String.t()) :: [{integer, integer}]
  def saddle_points(str) do
    rows = rows(str)

    for(
      {max_x, x} <- rows |> maxmin_with_idx(&Enum.max/1),
      {min_y, y} <- rows |> columns_from_rows() |> maxmin_with_idx(&Enum.min/1),
      min_y == max_x,
      do: {x, y}
    )
  end

  @spec columns_from_rows([[integer]]) :: [[integer]]
  defp columns_from_rows(rows), do: Enum.zip_with(rows, & &1)

  @spec maxmin_with_idx([[integer]], ([integer] -> integer)) :: [{integer, pos_integer}]
  defp maxmin_with_idx(matrix, aggregate),
    do: matrix |> Enum.map(aggregate) |> Enum.with_index(1)
end

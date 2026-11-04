defmodule FlowerField do
  @moduledoc """
  Annotates a flower field with counts of neighboring flowers.
  """

  @type coord :: {integer(), integer()}
  @type board :: tuple()

  @doc """
  Annotate empty spots next to flowers with the number of flowers next to them.
  """
  @spec annotate([String.t()]) :: [String.t()]
  def annotate(str_list) do
    board = parse_board(str_list)

    for {row, y} <- Enum.with_index(str_list) do
      for {cell, x} <- Enum.with_index(String.to_charlist(row)) do
        annotate_cell(cell, board, {x, y})
      end
      |> List.to_string()
    end
  end

  @spec annotate_cell(char(), board(), coord()) :: char()
  defp annotate_cell(?*, _board, _coords), do: ?*

  defp annotate_cell(_cell, board, coords) do
    board
    |> count_adjacent_flowers(coords)
    |> count_to_char()
  end

  @spec count_to_char(0..8) :: char()
  defp count_to_char(0), do: ?\s
  defp count_to_char(flowers), do: ?0 + flowers

  @spec count_adjacent_flowers(board(), coord()) :: 0..8
  defp count_adjacent_flowers(board, {x, y}) do
    {x, y}
    |> neighbor_coords()
    |> Enum.count(&flower_at?(board, &1))
  end

  @spec neighbor_coords(coord()) :: [coord()]
  defp neighbor_coords({x, y}) do
    for dy <- -1..1, dx <- -1..1, {dx, dy} != {0, 0} do
      {x + dx, y + dy}
    end
  end

  @spec flower_at?(board(), coord()) :: boolean()
  defp flower_at?(board, {x, y}) when y >= 0 and y < tuple_size(board) do
    row = elem(board, y)
    x >= 0 and x < tuple_size(row) and elem(row, x) == ?*
  end

  defp flower_at?(_board, _coords), do: false

  @spec parse_board([String.t()]) :: board()
  defp parse_board(str_list) do
    str_list
    |> Enum.map(fn row -> row |> String.to_charlist() |> List.to_tuple() end)
    |> List.to_tuple()
  end
end

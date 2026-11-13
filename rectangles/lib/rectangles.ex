defmodule Rectangles do
  @moduledoc """
  Counts the rectangles drawn in an ASCII diagram.
  """

  @type coord :: {row :: non_neg_integer(), col :: non_neg_integer()}
  @type board :: %{coord() => char()}
  @type span :: [non_neg_integer()] | Range.t()

  @doc """
  Count the number of ASCII rectangles.
  """
  @spec count(input :: String.t()) :: non_neg_integer()
  def count(input) do
    board = parse_board(input)
    corners = for {coord, ?+} <- board, do: coord

    for {top, left} <- corners,
        {bottom, right} <- corners,
        bottom > top and right > left,
        rectangle?(board, {top, left}, {bottom, right}),
        reduce: 0 do
      count -> count + 1
    end
  end

  @spec parse_board(String.t()) :: board()
  defp parse_board(input) do
    for {line, row} <- input |> String.split("\n", trim: true) |> Enum.with_index(),
        {char, col} <- line |> String.to_charlist() |> Enum.with_index(),
        into: %{},
        do: {{row, col}, char}
  end

  @spec rectangle?(board(), coord(), coord()) :: boolean()
  defp rectangle?(board, {top, left}, {bottom, right}) do
    board[{top, right}] == ?+ and
      board[{bottom, left}] == ?+ and
      edge?(board, [top], left..right, ?-) and
      edge?(board, [bottom], left..right, ?-) and
      edge?(board, top..bottom, [left], ?|) and
      edge?(board, top..bottom, [right], ?|)
  end

  @spec edge?(board(), span(), span(), char()) :: boolean()
  defp edge?(board, rows, cols, line_char) do
    Enum.all?(rows, fn row ->
      Enum.all?(cols, fn col -> board[{row, col}] in [?+, line_char] end)
    end)
  end
end

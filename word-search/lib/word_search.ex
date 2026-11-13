defmodule WordSearch do
  @moduledoc """
  Finds the positions of words hidden in a grid of letters.
  """

  defmodule Location do
    @moduledoc """
    Start and end positions of a word found in the grid.
    """

    defstruct [:from, :to]

    @type position :: %{row: pos_integer(), column: pos_integer()}
    @type t :: %Location{from: position(), to: position()}
  end

  # Tuples give O(1) access to any letter by index, which the search needs
  # when walking in every direction from each starting cell.
  @typedoc "A tuple of rows, each row a tuple of single-letter strings."
  @type grid :: tuple()

  # 0-indexed {row, col}. Can be negative or past the edge while walking.
  @type coord :: {integer(), integer()}
  @type direction :: {-1 | 0 | 1, -1 | 0 | 1}

  # Horizontal, vertical and diagonal, in both senses.
  @directions [{0, 1}, {0, -1}, {1, 0}, {-1, 0}, {1, 1}, {-1, -1}, {1, -1}, {-1, 1}]

  @doc """
  Find the start and end positions of words in a grid of letters.
  Row and column positions are 1 indexed.
  """
  @spec search(str :: String.t(), words :: [String.t()]) :: %{
          String.t() => nil | Location.t()
        }
  def search(str, words) do
    grid = str_to_grid(str)

    Map.new(words, &{&1, search_word(grid, &1)})
  end

  @spec str_to_grid(String.t()) :: grid()
  defp str_to_grid(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&row_to_tuple/1)
    |> List.to_tuple()
  end

  @spec row_to_tuple(String.t()) :: tuple()
  defp row_to_tuple(row), do: row |> String.graphemes() |> List.to_tuple()

  @spec cell(grid(), coord()) :: String.t() | nil
  defp cell(grid, {row, col})
       when row >= 0 and row < tuple_size(grid) and
              col >= 0 and col < tuple_size(elem(grid, row)),
       do: grid |> elem(row) |> elem(col)

  defp cell(_grid, _coord), do: nil

  @spec search_word(grid(), String.t()) :: Location.t() | nil
  defp search_word(_grid, ""), do: nil

  defp search_word(grid, word) do
    letters = String.graphemes(word)

    grid
    |> placements()
    |> Enum.find(fn {start, direction} -> word_at?(grid, letters, start, direction) end)
    |> to_location(length(letters))
  end

  @spec placements(grid()) :: [{coord(), direction()}]
  defp placements(grid) do
    for row <- indices(grid),
        col <- indices(elem(grid, row)),
        direction <- @directions,
        do: {{row, col}, direction}
  end

  @spec indices(tuple()) :: Range.t()
  defp indices(tuple), do: 0..(tuple_size(tuple) - 1)//1

  @spec word_at?(grid(), [String.t()], coord(), direction()) :: boolean()
  defp word_at?(_grid, [], _coord, _direction), do: true

  defp word_at?(grid, [letter | rest], coord, direction) do
    cell(grid, coord) == letter and
      word_at?(grid, rest, advance(coord, direction, 1), direction)
  end

  @spec to_location({coord(), direction()} | nil, non_neg_integer()) :: Location.t() | nil
  defp to_location(nil, _length), do: nil

  defp to_location({start, direction}, length),
    do: %Location{from: position(start), to: position(advance(start, direction, length - 1))}

  @spec advance(coord(), direction(), integer()) :: coord()
  defp advance({row, col}, {d_row, d_col}, steps), do: {row + steps * d_row, col + steps * d_col}

  @spec position(coord()) :: Location.position()
  defp position({row, col}), do: %{row: row + 1, column: col + 1}
end

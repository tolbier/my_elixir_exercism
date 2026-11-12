defmodule Queens do
  @moduledoc """
  Positions two queens on a chessboard and checks whether they can attack each other.
  """

  @type position :: {integer(), integer()}
  @type t :: %__MODULE__{black: position() | nil, white: position() | nil}
  defstruct [:white, :black]

  defguardp on_board(position)
            when is_tuple(position) and tuple_size(position) == 2 and
                   elem(position, 0) in 0..7 and elem(position, 1) in 0..7

  defguardp valid_position(position) when is_nil(position) or on_board(position)

  @doc """
  Creates a new set of Queens
  """
  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(opts \\ [])
  def new([]), do: new(white: nil, black: nil)
  def new(white: white), do: new(white: white, black: nil)
  def new(black: black), do: new(white: nil, black: black)
  def new(black: black, white: white), do: new(white: white, black: black)
  def new(white: nil, black: nil), do: %__MODULE__{}

  def new(white: white, black: black)
      when white != black and valid_position(white) and valid_position(black),
      do: %__MODULE__{white: white, black: black}

  # Any other input (unknown color, off-board position, same square) is invalid.
  def new(_), do: raise(ArgumentError)

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(__MODULE__.t()) :: String.t()
  def to_string(queens) do
    for row <- 0..7 do
      for col <- 0..7 do
        cell(queens, {row, col})
      end
      |> Enum.join(" ")
    end
    |> Enum.join("\n")
  end

  @spec cell(__MODULE__.t(), position()) :: String.t()
  defp cell(%__MODULE__{white: white, black: black}, coords) do
    case coords do
      ^white -> "W"
      ^black -> "B"
      _ -> "_"
    end
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(__MODULE__.t()) :: boolean()
  def can_attack?(%__MODULE__{white: {white_row, white_col}, black: {black_row, black_col}}) do
    white_row == black_row or
      white_col == black_col or
      abs(white_row - black_row) == abs(white_col - black_col)
  end

  def can_attack?(_), do: false
end

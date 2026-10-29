defmodule Grains do
  @moduledoc """
  Calculates the number of grains on a chessboard square, doubling each square.
  """

  @doc """
  Calculate two to the power of the input minus one.
  """
  @spec square(pos_integer()) :: {:ok, pos_integer()} | {:error, String.t()}

  def square(number) when number >= 1 and number <= 64, do: {:ok, do_square(number)}
  def square(_), do: {:error, "The requested square must be between 1 and 64 (inclusive)"}

  @spec do_square(pos_integer()) :: pos_integer()
  defp do_square(1), do: 1

  defp do_square(number), do: do_square(number - 1) * 2

  @doc """
  Adds square of each number from 1 to 64.
  """
  @spec total :: {:ok, pos_integer()}
  def total do
    {:ok,
     1..64
     |> Enum.map(&do_square/1)
     |> Enum.sum()}
  end
end

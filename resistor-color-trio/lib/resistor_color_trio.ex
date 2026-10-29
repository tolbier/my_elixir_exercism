defmodule ResistorColorTrio do
  @moduledoc """
  Calculates a resistor's resistance value from its three color bands.
  """

  @color_values %{
    black: {0, 1},
    brown: {1, 10},
    red: {2, 100},
    orange: {3, 1_000},
    yellow: {4, 10_000},
    green: {5, 100_000},
    blue: {6, 1_000_000},
    violet: {7, 10_000_000},
    grey: {8, 100_000_000},
    white: {9, 1_000_000_000}
  }

  @doc """
  Calculate the resistance value in ohms from resistor colors
  """
  @spec label(colors :: [atom]) :: {number, :ohms | :kiloohms | :megaohms | :gigaohms}
  def label([first, second, third | _rest]) do
    evaluate_ohms((value(first) * 10 + value(second)) * multiplier(third))
  end

  @spec value(atom) :: non_neg_integer
  defp value(color), do: fetch(color, 0)

  @spec multiplier(atom) :: pos_integer
  defp multiplier(color), do: fetch(color, 1)

  @spec fetch(atom, 0 | 1) :: number
  defp fetch(color, n), do: elem(@color_values[color], n)

  @spec evaluate_ohms(number) :: {number, :ohms | :kiloohms | :megaohms | :gigaohms}
  defp evaluate_ohms(ohms) when ohms >= 1_000_000_000, do: {div(ohms, 1_000_000_000), :gigaohms}
  defp evaluate_ohms(ohms) when ohms >= 1_000_000, do: {div(ohms, 1_000_000), :megaohms}
  defp evaluate_ohms(ohms) when ohms >= 1_000, do: {div(ohms, 1_000), :kiloohms}
  defp evaluate_ohms(ohms), do: {ohms, :ohms}
end

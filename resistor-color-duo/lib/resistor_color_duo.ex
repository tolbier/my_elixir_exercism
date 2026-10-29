defmodule ResistorColorDuo do
  @moduledoc """
  Calculates the two-digit resistance value from the first two color bands.
  """

  @color_values %{
    black: 0,
    brown: 1,
    red: 2,
    orange: 3,
    yellow: 4,
    green: 5,
    blue: 6,
    violet: 7,
    grey: 8,
    white: 9
  }
  @doc """
  Calculate a resistance value from two colors
  """
  @spec value(colors :: [atom]) :: integer
  def value([first, second | _]) do
    @color_values[first] * 10 + @color_values[second]
  end
end

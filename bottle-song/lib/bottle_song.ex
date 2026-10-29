defmodule BottleSong do
  @moduledoc """
  Handles lyrics of the popular children song: Ten Green Bottles
  """

  @numbers %{
    0 => "no",
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five",
    6 => "six",
    7 => "seven",
    8 => "eight",
    9 => "nine",
    10 => "ten"
  }

  @spec recite(pos_integer, pos_integer) :: String.t()
  def recite(start_bottle, take_down) do
    for i <- start_bottle..(start_bottle - take_down + 1)//-1 do
      recite(i)
    end
    |> Enum.join("\n\n")
  end

  @spec recite(pos_integer) :: String.t()
  defp recite(number) do
    """
    #{number_cap(number)} green #{bottles(number)} hanging on the wall,
    #{number_cap(number)} green #{bottles(number)} hanging on the wall,
    And if one green bottle should accidentally fall,
    There'll be #{number(number - 1)} green #{bottles(number - 1)} hanging on the wall.\
    """
  end

  @spec number(non_neg_integer) :: String.t()
  defp number(number), do: @numbers[number]

  @spec number_cap(non_neg_integer) :: String.t()
  defp number_cap(number), do: String.capitalize(number(number))

  @spec bottles(non_neg_integer) :: String.t()
  defp bottles(1), do: "bottle"
  defp bottles(_), do: "bottles"
end

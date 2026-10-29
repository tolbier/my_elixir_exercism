defmodule TwelveDays do
  @moduledoc """
  Generates the verses of "The Twelve Days of Christmas" song.
  """

  @values {
    {"first", "a Partridge in a Pear Tree"},
    {"second", "two Turtle Doves"},
    {"third", "three French Hens"},
    {"fourth", "four Calling Birds"},
    {"fifth", "five Gold Rings"},
    {"sixth", "six Geese-a-Laying"},
    {"seventh", "seven Swans-a-Swimming"},
    {"eighth", "eight Maids-a-Milking"},
    {"ninth", "nine Ladies Dancing"},
    {"tenth", "ten Lords-a-Leaping"},
    {"eleventh", "eleven Pipers Piping"},
    {"twelfth", "twelve Drummers Drumming"}
  }
  {ordinals, gifts} =
    @values
    |> Tuple.to_list()
    |> Enum.unzip()

  @num_verses tuple_size(@values)

  @ordinals List.to_tuple(ordinals)
  @gifts gifts |> Enum.reverse()

  @doc """
  Given a `number`, return the song's verse for that specific day, including
  all gifts for previous days in the same line.
  """
  @spec verse(number :: integer) :: String.t()
  def verse(number) do
    ordinal = elem(@ordinals, number - 1)

    gifts_phrase =
      @gifts
      |> Enum.slice(@num_verses - number, number)
      |> gifts_phrase()

    "On the #{ordinal} day of Christmas my true love gave to me: #{gifts_phrase}."
  end

  @spec gifts_phrase([String.t()]) :: String.t()
  defp gifts_phrase([first]), do: first
  defp gifts_phrase([first, second]), do: "#{first}, and #{second}"
  defp gifts_phrase([first | rest]), do: "#{first}, #{gifts_phrase(rest)}"

  @doc """
  Given a `starting_verse` and an `ending_verse`, return the verses for each
  included day, one per line.
  """
  @spec verses(starting_verse :: integer, ending_verse :: integer) :: String.t()
  def verses(starting_verse, ending_verse) do
    starting_verse..ending_verse
    |> Enum.map_join("\n", &verse/1)
  end

  @doc """
  Sing all 12 verses, in order, one verse per line.
  """
  @spec sing() :: String.t()
  def sing, do: verses(1, @num_verses)
end

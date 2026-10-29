defmodule ZebraPuzzle do
  @moduledoc """
  Solves the zebra puzzle by representing each attribute as a house position.
  """

  @type nationality :: :englishman | :norwegian | :japanese | :spaniard | :ukrainian
  @type position :: 0..4
  @type solution :: %{water: nationality(), zebra: nationality()}

  @nationalities [:englishman, :norwegian, :japanese, :spaniard, :ukrainian]

  @doc """
  Determine who drinks the water.
  """
  @spec drinks_water() :: nationality()
  def drinks_water(), do: solution().water

  @doc """
  Determine who owns the zebra.
  """
  @spec owns_zebra() :: nationality()
  def owns_zebra(), do: solution().zebra

  @spec solution() :: solution()
  defp solution() do
    positions = permutations(Enum.to_list(0..4))

    [solution] =
      for [englishman, norwegian, japanese, spaniard, ukrainian] = nationalities <- positions,
          norwegian == 0,
          [red, green, ivory, yellow, blue] <- positions,
          englishman == red,
          green == ivory + 1,
          abs(norwegian - blue) == 1,
          [water, coffee, tea, milk, orange_juice] <- positions,
          green == coffee,
          ukrainian == tea,
          milk == 2,
          [dancing, painting, reading, chess, football] <- positions,
          yellow == painting,
          football == orange_juice,
          japanese == chess,
          [zebra, dog, snail, fox, horse] <- positions,
          spaniard == dog,
          snail == dancing,
          abs(reading - fox) == 1,
          abs(painting - horse) == 1 do
        %{
          water: nationality_at(nationalities, water),
          zebra: nationality_at(nationalities, zebra)
        }
      end

    solution
  end

  @spec nationality_at([position()], position()) :: nationality()
  defp nationality_at(positions, position) do
    index = Enum.find_index(positions, &(&1 == position))
    Enum.at(@nationalities, index)
  end

  @spec permutations([position()]) :: [[position()]]
  defp permutations([]), do: [[]]

  defp permutations(values) do
    for value <- values,
        rest <- permutations(List.delete(values, value)),
        do: [value | rest]
  end
end

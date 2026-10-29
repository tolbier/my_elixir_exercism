defmodule DndCharacter do
  @moduledoc """
  Generates random Dungeons & Dragons characters with rolled ability scores.
  """

  @type t :: %__MODULE__{
          strength: pos_integer(),
          dexterity: pos_integer(),
          constitution: pos_integer(),
          intelligence: pos_integer(),
          wisdom: pos_integer(),
          charisma: pos_integer(),
          hitpoints: pos_integer()
        }

  defstruct ~w[strength dexterity constitution intelligence wisdom charisma hitpoints]a

  @spec modifier(pos_integer()) :: integer()
  def modifier(n), do: div(n, 2) - 5

  @spec ability :: pos_integer()
  def ability() do
    1..3
    |> Enum.map(fn _ -> dice() end)
    |> Enum.sum()
  end

  @spec dice() :: pos_integer()
  defp dice(), do: Enum.random(1..6)

  @spec character :: t()
  def character do
    constitution = ability()

    %__MODULE__{
      strength: ability(),
      dexterity: ability(),
      constitution: constitution,
      intelligence: ability(),
      wisdom: ability(),
      charisma: ability(),
      hitpoints: 10 + modifier(constitution)
    }
  end
end

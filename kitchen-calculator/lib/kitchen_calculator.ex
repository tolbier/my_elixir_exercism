defmodule KitchenCalculator do
  @milliliter_to_milliliter_rate 1
  @cup_to_milliliter_rate 240
  @fluid_ounce_to_milliliter_rate 30
  @teaspoon_to_milliliter_rate 5
  @tablespoon_to_milliliter_rate 15

  def get_volume({_unit, amount}), do: amount

  def to_milliliter({:cup, amount}), do: to_milliliter(amount, @cup_to_milliliter_rate)

  def to_milliliter({:fluid_ounce, amount}),
    do: to_milliliter(amount, @fluid_ounce_to_milliliter_rate)

  def to_milliliter({:teaspoon, amount}), do: to_milliliter(amount, @teaspoon_to_milliliter_rate)

  def to_milliliter({:tablespoon, amount}),
    do: to_milliliter(amount, @tablespoon_to_milliliter_rate)

  def to_milliliter({:milliliter, amount}),
    do: to_milliliter(amount, @milliliter_to_milliliter_rate)

  def to_milliliter(amount, rate), do: {:milliliter, amount * rate}

  def from_milliliter({:milliliter, amount}, unit = :milliliter), do: {unit, amount}

  def from_milliliter({:milliliter, amount}, unit = :cup),
    do: from_milliliter(amount, unit, @cup_to_milliliter_rate)

  def from_milliliter({:milliliter, amount}, unit = :fluid_ounce),
    do: from_milliliter(amount, unit, @fluid_ounce_to_milliliter_rate)

  def from_milliliter({:milliliter, amount}, unit = :teaspoon),
    do: from_milliliter(amount, unit, @teaspoon_to_milliliter_rate)

  def from_milliliter({:milliliter, amount}, unit = :tablespoon),
    do: from_milliliter(amount, unit, @tablespoon_to_milliliter_rate)

  def from_milliliter(amount, unit, rate), do: {unit, amount / rate}

  def convert(volume_pair, unit), do: volume_pair |> to_milliliter |> from_milliliter(unit)
end

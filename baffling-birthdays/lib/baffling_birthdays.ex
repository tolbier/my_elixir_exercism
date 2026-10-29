defmodule BafflingBirthdays do
  @moduledoc """
  Estimate the probability of shared birthdays in a group of people.
  """

  @spec shared_birthday?(birthdates :: [Date.t()]) :: boolean()
  def shared_birthday?(birthdates) do
    birthdates
    |> Enum.map(&{&1.month, &1.day})
    |> Enum.sort()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  @spec random_birthdates(group_size :: integer()) :: [Date.t()]
  def random_birthdates(group_size) do
    for _ <- 1..group_size do
      Date.add(~D[2025-01-01], Enum.random(0..364))
    end
  end

  @spec estimated_probability_of_shared_birthday(group_size :: integer()) :: float()

  def estimated_probability_of_shared_birthday(group_size) do
    simulations = 600

    matches =
      1..simulations
      |> Enum.count(fn _ ->
        group_size
        |> random_birthdates()
        |> shared_birthday?()
      end)

    matches / simulations * 100
  end
end

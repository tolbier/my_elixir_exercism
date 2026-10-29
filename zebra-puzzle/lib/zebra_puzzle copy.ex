defmodule ZebraPuzzle.HouseBased do
  @moduledoc """
  Solves the zebra puzzle using its house clues.
  """

  @type nationality :: :englishman | :norwegian | :japanese | :spaniard | :ukrainian
  @type house :: %{required(:number) => 0..4, optional(atom()) => atom()}
  @type combination :: [house()]
  @type combinations :: [combination()]
  @type attribute :: {atom(), atom() | integer()}

  @numbers Enum.to_list(0..4)
  @nationalities [:englishman, :norwegian, :japanese, :spaniard, :ukrainian]
  @colors [:red, :green, :ivory, :yellow, :blue]
  @pets [:zebra, :dog, :snail, :fox, :horse]
  @drinks [:water, :coffee, :tea, :milk, :orange_juice]
  @hobbies [:dancing, :painting, :reading, :chess, :football]

  @doc """
  Determine who drinks the water
  """
  @spec drinks_water() :: nationality()
  def drinks_water() do
    generate_solution()
    |> solution_nationality(&(&1.drink == :water))
  end

  @doc """
  Determine who owns the zebra
  """
  @spec owns_zebra() :: nationality()
  def owns_zebra() do
    generate_solution()
    |> solution_nationality(&(&1.pet == :zebra))
  end

  @spec solution_nationality(combinations(), (house() -> boolean())) :: nationality()
  defp solution_nationality([solution], fun) do
    Enum.find(solution, fun).nationality
  end

  @spec generate_solution() :: combinations()
  defp generate_solution() do
    assign_numbers()
    |> assign_nationalities()
    |> rule_10()
    |> assign_colors()
    |> rule_2()
    |> rule_6()
    |> rule_15()
    |> assign_drinks()
    |> rule_4()
    |> rule_5()
    |> rule_9()
    |> assign_hobbies()
    |> rule_8()
    |> rule_13()
    |> rule_14()
    |> assign_pets()
    |> rule_3()
    |> rule_7()
    |> rule_11()
    |> rule_12()
  end

  @spec assign_numbers() :: combinations()
  defp assign_numbers(), do: [Enum.map(@numbers, &%{number: &1})]

  @spec assign_nationalities(combinations()) :: combinations()
  defp assign_nationalities(combs), do: assign(combs, :nationality, @nationalities)

  @spec assign_colors(combinations()) :: combinations()
  defp assign_colors(combs), do: assign(combs, :color, @colors)
  @spec assign_drinks(combinations()) :: combinations()
  defp assign_drinks(combs), do: assign(combs, :drink, @drinks)
  @spec assign_hobbies(combinations()) :: combinations()
  defp assign_hobbies(combs), do: assign(combs, :hobby, @hobbies)
  @spec assign_pets(combinations()) :: combinations()
  defp assign_pets(combs), do: assign(combs, :pet, @pets)

  @spec assign(combinations(), atom(), [atom()]) :: combinations()
  defp assign(combs, key, values) do
    Enum.flat_map(combs, &assign_houses(&1, key, values))
  end

  @spec assign_houses(combination(), atom(), [atom()]) :: combinations()
  defp assign_houses([], _key, []), do: [[]]

  defp assign_houses([house | houses], key, values) do
    Enum.flat_map(values, fn value ->
      remaining = List.delete(values, value)

      Enum.map(assign_houses(houses, key, remaining), fn combination ->
        [Map.put(house, key, value) | combination]
      end)
    end)
  end

  # 2. The Englishman lives in the red house.
  @spec rule_2(combinations()) :: combinations()
  defp rule_2(combs) do
    same_house(combs, color: :red, nationality: :englishman)
  end

  # 3. The Spaniard owns the dog.
  @spec rule_3(combinations()) :: combinations()
  defp rule_3(combs) do
    same_house(combs, nationality: :spaniard, pet: :dog)
  end

  # 4. The person in the green house drinks coffee.
  @spec rule_4(combinations()) :: combinations()
  defp rule_4(combs) do
    same_house(combs, color: :green, drink: :coffee)
  end

  # 5. The Ukrainian drinks tea.
  @spec rule_5(combinations()) :: combinations()
  defp rule_5(combs) do
    same_house(combs, nationality: :ukrainian, drink: :tea)
  end

  # 6. The green house is immediately to the right of the ivory house.
  @spec rule_6(combinations()) :: combinations()
  defp rule_6(combs) do
    house_right_of(combs, {:color, :green}, {:color, :ivory})
  end

  # 7. The snail owner likes to go dancing.
  @spec rule_7(combinations()) :: combinations()
  defp rule_7(combs) do
    same_house(combs, hobby: :dancing, pet: :snail)
  end

  # 8. The person in the yellow house is a painter.
  @spec rule_8(combinations()) :: combinations()
  defp rule_8(combs) do
    same_house(combs, color: :yellow, hobby: :painting)
  end

  # 9. The person in the middle house drinks milk.
  @spec rule_9(combinations()) :: combinations()
  defp rule_9(combs) do
    same_house(combs, number: 2, drink: :milk)
  end

  # 10. The Norwegian lives in the first house.
  @spec rule_10(combinations()) :: combinations()
  defp rule_10(combs) do
    same_house(combs, number: 0, nationality: :norwegian)
  end

  # 11. The person who enjoys reading lives in the house next to the person with the fox.
  @spec rule_11(combinations()) :: combinations()
  defp rule_11(combs) do
    house_next_to(combs, {:hobby, :reading}, {:pet, :fox})
  end

  # 12. The painter's house is next to the house with the horse.
  @spec rule_12(combinations()) :: combinations()
  defp rule_12(combs) do
    house_next_to(combs, {:hobby, :painting}, {:pet, :horse})
  end

  # 13. The person who plays football drinks orange juice.
  @spec rule_13(combinations()) :: combinations()
  defp rule_13(combs) do
    same_house(combs, hobby: :football, drink: :orange_juice)
  end

  # 14. The Japanese person plays chess.
  @spec rule_14(combinations()) :: combinations()
  defp rule_14(combs) do
    same_house(combs, hobby: :chess, nationality: :japanese)
  end

  # 15. The Norwegian lives next to the blue house.
  @spec rule_15(combinations()) :: combinations()
  defp rule_15(combs) do
    house_next_to(combs, {:nationality, :norwegian}, {:color, :blue})
  end

  @spec house_right_of(combinations(), attribute(), attribute()) :: combinations()
  defp house_right_of(combs, first, second) do
    relative_houses(combs, first, second, &(&1 == 1))
  end

  @spec house_next_to(combinations(), attribute(), attribute()) :: combinations()
  defp house_next_to(combs, first, second) do
    relative_houses(combs, first, second, &(abs(&1) == 1))
  end

  @spec relative_houses(combinations(), attribute(), attribute(), (integer() -> boolean())) ::
          combinations()
  defp relative_houses(combs, {key_a, value_a}, {key_b, value_b}, valid_distance?) do
    Enum.filter(combs, fn combination ->
      first = Enum.find(combination, &(Map.fetch!(&1, key_a) == value_a))
      second = Enum.find(combination, &(Map.fetch!(&1, key_b) == value_b))

      valid_distance?.(first.number - second.number)
    end)
  end

  @spec same_house(combinations(), [attribute()]) :: combinations()
  defp same_house(combs, attributes) do
    Enum.filter(combs, fn combination ->
      Enum.any?(combination, &matches_attributes?(&1, attributes))
    end)
  end

  @spec matches_attributes?(house(), [attribute()]) :: boolean()
  defp matches_attributes?(house, attributes) do
    Enum.all?(attributes, fn {key, value} -> Map.fetch!(house, key) == value end)
  end
end

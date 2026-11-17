defmodule Poker do
  @moduledoc """
  Picks the best hand(s) from a list of poker hands.
  """

  @categories [
    :high_card,
    :pair,
    :two_pair,
    :three_of_a_kind,
    :straight,
    :flush,
    :full_house,
    :four_of_a_kind,
    :straight_flush
  ]

  @category_rank @categories |> Enum.with_index() |> Map.new()

  @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
  @rank_value @ranks |> Enum.with_index(2) |> Map.new()

  @ace 14

  @typep category ::
           :high_card
           | :pair
           | :two_pair
           | :three_of_a_kind
           | :straight
           | :flush
           | :full_house
           | :four_of_a_kind
           | :straight_flush
  # 1 only appears as the low ace of A 2 3 4 5
  @typep rank :: 1..14
  @typep card :: {rank(), suit :: String.t()}
  @typep score :: {category_rank :: 0..8, tiebreakers :: [rank()]}

  @doc """
  Given a list of poker hands, return a list containing the highest scoring hand.

  If two or more hands tie, return the list of tied hands in the order they were received.

  The basic rules and hand rankings for Poker can be found at:

  https://en.wikipedia.org/wiki/List_of_poker_hands

  For this exercise, we'll consider the game to be using no Jokers,
  so five-of-a-kind hands will not be tested. We will also consider
  the game to be using multiple decks, so it is possible for multiple
  players to have identical cards.

  Aces can be used in low (A 2 3 4 5) or high (10 J Q K A) straights, but do not count as
  a high card in the former case.

  For example, (A 2 3 4 5) will lose to (2 3 4 5 6).

  You can also assume all inputs will be valid, and do not need to perform error checking
  when parsing card values. All hands will be a list of 5 strings, containing a number
  (or letter) for the rank, followed by the suit.

  Ranks (lowest to highest): 2 3 4 5 6 7 8 9 10 J Q K A
  Suits (order doesn't matter): C D H S

  Example hand: ~w(4S 5H 4C 5D 4H) # Full house, 5s over 4s
  """
  @spec best_hand([[String.t()]]) :: [[String.t()]]
  def best_hand(hands) do
    hands
    |> Enum.map(&{score_hand(&1), &1})
    |> winners()
  end

  @spec winners([{score(), [String.t()]}]) :: [[String.t()]]
  defp winners(scored_hands) do
    {best_score, _hand} = Enum.max_by(scored_hands, fn {score, _hand} -> score end)
    for {^best_score, hand} <- scored_hands, do: hand
  end

  @spec score_hand([String.t()]) :: score()
  defp score_hand(hand) do
    cards = Enum.map(hand, &parse_card/1)
    {ranks, counts} = group_ranks(cards)
    category = category(counts, straight?(ranks), flush?(cards))
    {@category_rank[category], ranks}
  end

  @spec parse_card(String.t()) :: card()
  defp parse_card(card) do
    {rank, suit} = String.split_at(card, -1)
    {@rank_value[rank], suit}
  end

  # Distinct ranks and how many times each appears, biggest group first and
  # ties by rank: 5 5 5 K K gives {[5, 13], [3, 2]}. The ranks double as the
  # tiebreakers, with the low ace already counted as 1.
  @spec group_ranks([card()]) :: {[rank()], [pos_integer]}
  defp group_ranks(cards) do
    {ranks, counts} =
      cards
      |> Enum.frequencies_by(fn {rank, _suit} -> rank end)
      |> Enum.sort_by(fn {rank, count} -> {count, rank} end, :desc)
      |> Enum.unzip()

    {ace_low(ranks), counts}
  end

  # In A 2 3 4 5 the ace counts as 1, so the straight is 5-high
  @spec ace_low([rank()]) :: [rank()]
  defp ace_low([@ace, 5, 4, 3, 2]), do: [5, 4, 3, 2, 1]
  defp ace_low(ranks), do: ranks

  # Five distinct ranks, highest first, spanning exactly five values
  @spec straight?([rank()]) :: boolean
  defp straight?([highest, _, _, _, lowest]), do: highest - lowest == 4
  defp straight?(_ranks), do: false

  @spec flush?([card()]) :: boolean
  defp flush?([{_, suit}, {_, suit}, {_, suit}, {_, suit}, {_, suit}]), do: true
  defp flush?(_cards), do: false

  # Only straight and flush depend on the order of these clauses: the group
  # patterns are exact, so each matches a single category.
  @spec category([pos_integer], boolean, boolean) :: category()
  defp category(_counts, _straight = true, _flush = true), do: :straight_flush
  defp category([4, 1], _straight, _flush), do: :four_of_a_kind
  defp category([3, 2], _straight, _flush), do: :full_house
  defp category(_counts, _straight, _flush = true), do: :flush
  defp category(_counts, _straight = true, _flush), do: :straight
  defp category([3, 1, 1], _straight, _flush), do: :three_of_a_kind
  defp category([2, 2, 1], _straight, _flush), do: :two_pair
  defp category([2, 1, 1, 1], _straight, _flush), do: :pair
  defp category([1, 1, 1, 1, 1], _straight, _flush), do: :high_card
end

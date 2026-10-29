defmodule GottaSnatchEmAll do
  import MapSet

  @type card :: String.t()
  @type collection :: MapSet.t(card())

  @spec new_collection(card()) :: collection()
  def new_collection(card) do
    new([card])
  end

  @spec add_card(card(), collection()) :: {boolean(), collection()}
  def add_card(card, collection) do
    {member?(collection, card), put(collection, card)}
  end

  @spec trade_card(card(), card(), collection()) :: {boolean(), collection()}
  def trade_card(your_card, their_card, collection) do
    {
      member?(collection, your_card) and not member?(collection, their_card),
      collection
      |> delete(your_card)
      |> put(their_card)
    }
  end

  @spec remove_duplicates([card()]) :: [card()]
  def remove_duplicates(cards), do: cards |> new |> Enum.sort()

  @spec extra_cards(collection(), collection()) :: non_neg_integer()
  def extra_cards(your_collection, their_collection) do
    your_collection
    |> difference(their_collection)
    |> size
  end

  @spec boring_cards([collection()]) :: [card()]
  def boring_cards([]), do: []

  def boring_cards(collections) do
    collections
    |> Enum.reduce(&intersection/2)
    |> Enum.sort()
  end

  @spec total_cards([collection()]) :: non_neg_integer()
  def total_cards([]), do: 0

  def total_cards(collections) do
    collections
    |> Enum.reduce(&union/2)
    |> size
  end

  @spec split_shiny_cards(collection()) :: {[card()], [card()]}
  def split_shiny_cards(collection) do
    shiny? = &String.starts_with?(&1, "Shiny")

    collection
    |> split_with(shiny?)
    |> then(fn {shiny, not_shiny} ->
      {Enum.sort(shiny), Enum.sort(not_shiny)}
    end)
  end
end

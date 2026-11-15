defmodule BookStore do
  @moduledoc """
  Calculates the cheapest price for a basket of books from a five-book series.
  """

  @typedoc "A book is represented by its number in the 5-book series"
  @type book :: 1 | 2 | 3 | 4 | 5

  @typep copy_counts :: [pos_integer]
  # Cheapest price already computed for each copy_counts.
  @typep cache :: %{optional(copy_counts()) => non_neg_integer}

  @doc """
  Calculate lowest price (in cents) for a shopping basket containing books.
  """
  @spec total(basket :: [book]) :: non_neg_integer
  def total(basket), do: basket |> count_copies() |> cheapest_price()

  @spec cheapest_price(copy_counts()) :: non_neg_integer
  defp cheapest_price(copy_counts), do: copy_counts |> cheapest_price(%{}) |> elem(0)

  @spec cheapest_price(copy_counts(), cache()) :: {non_neg_integer, cache()}
  defp cheapest_price([], cache), do: {0, cache}

  defp cheapest_price(copy_counts, cache) when is_map_key(cache, copy_counts),
    do: {Map.fetch!(cache, copy_counts), cache}

  defp cheapest_price(copy_counts, cache) do
    {prices, cache} =
      copy_counts
      |> length()
      |> BitMasks.non_empty()
      |> Enum.map_reduce(cache, &price_with_group(copy_counts, &1, &2))

    price = Enum.min(prices)
    {price, Map.put(cache, copy_counts, price)}
  end

  @spec price_with_group(copy_counts(), BitMasks.mask(), cache()) :: {non_neg_integer, cache()}
  defp price_with_group(copy_counts, mask, cache) do
    {rest_price, cache} =
      copy_counts
      |> BitMasks.apply_mask(mask)
      |> cheapest_price(cache)

    {BitMasks.cost(mask) + rest_price, cache}
  end

  @spec count_copies([book]) :: copy_counts()
  defp count_copies(basket) do
    basket
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
  end
end

defmodule BitMasks do
  @moduledoc """
  Generates bit masks: lists of 0s and 1s marking which of `n` positions are chosen.

  A mask also selects a group of different books, so it can be priced with `cost/1`.
  """

  @typedoc "A list of binary digits where 1 marks a chosen position, e.g. `[1, 0, 1]`"
  @type mask :: [0 | 1]

  # Price in cents of a group of different books, by group size (1 to 5).
  @cost_per_group {800, 1520, 2160, 2560, 3000}

  @doc """
  Returns all masks of `n` digits with exactly `k` ones ("n choose k").

      iex> BitMasks.choose(3, 2)
      [[1, 1, 0], [1, 0, 1], [0, 1, 1]]
  """
  @spec choose(non_neg_integer, non_neg_integer) :: [mask()]
  def choose(n, 0), do: [List.duplicate(0, n)]
  def choose(n, k) when k > n, do: []

  # The first digit is either a 1 (one fewer position left to choose) or a 0
  # (the same positions left to choose); the rest are the masks of n - 1 digits.
  def choose(n, k) do
    starting_with_one = for mask <- choose(n - 1, k - 1), do: [1 | mask]
    starting_with_zero = for mask <- choose(n - 1, k), do: [0 | mask]
    starting_with_one ++ starting_with_zero
  end

  @doc """
  Returns all masks of `n` digits with at least one 1, ordered by number of ones.

      iex> BitMasks.non_empty(2)
      [[1, 0], [0, 1], [1, 1]]
  """
  @spec non_empty(non_neg_integer) :: [mask()]
  # The `//1` step keeps the range empty when `n` is 0 (`1..0` would count down).
  def non_empty(n), do: Enum.flat_map(1..n//1, &choose(n, &1))

  @doc """
  Subtracts the mask from the copy counts, dropping the counts that reach zero
  and keeping the rest sorted from most to fewest copies.

      iex> BitMasks.apply_mask([2, 2, 1], [1, 0, 1])
      [2, 1]
  """
  @spec apply_mask([pos_integer], mask()) :: [pos_integer]
  def apply_mask(copy_counts, mask) do
    copy_counts
    |> Enum.zip_with(mask, &-/2)
    |> Enum.reject(&(&1 == 0))
    |> Enum.sort(:desc)
  end

  @doc """
  Returns the price in cents of the group of different books marked with 1.

  The mask must have between one and five 1s.

      iex> BitMasks.cost([1, 0, 1])
      1520
  """
  @spec cost(mask()) :: pos_integer
  def cost(mask), do: elem(@cost_per_group, Enum.sum(mask) - 1)
end

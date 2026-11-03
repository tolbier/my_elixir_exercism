defmodule Change do
  @moduledoc """
  Finds the fewest coins needed to make a target amount of change.
  """

  @doc """
    Determine the least number of coins to be given to the user such
    that the sum of the coins' value would equal the correct amount of change.
    It returns {:error, "cannot change"} if it is not possible to compute the
    right amount of coins. Otherwise returns the tuple {:ok, list_of_coins}

    ## Examples

      iex> Change.generate([5, 10, 15], 3)
      {:error, "cannot change"}

      iex> Change.generate([1, 5, 10], 18)
      {:ok, [1, 1, 1, 5, 10]}

  """

  @spec generate([pos_integer()], integer()) :: {:ok, [pos_integer()]} | {:error, String.t()}
  def generate(_coins, target) when target < 0, do: {:error, "cannot change"}

  def generate(coins, target) do
    coins = coins |> Enum.uniq() |> Enum.sort(:desc)

    case do_generate(coins, target, [], nil) do
      nil -> {:error, "cannot change"}
      result -> {:ok, Enum.sort(result)}
    end
  end

  @spec do_generate([pos_integer()], non_neg_integer(), [pos_integer()], [pos_integer()] | nil) ::
          [pos_integer()] | nil
  defp do_generate(_coins, 0, acc, _best), do: acc

  defp do_generate([largest | _], target, acc, [_ | _] = best)
       when length(acc) + div(target + largest - 1, largest) >= length(best),
       do: best

  defp do_generate(coins, target, acc, best) do
    for coin <- coins, coin <= target, reduce: best do
      best ->
        remaining_coins = Enum.filter(coins, &(&1 <= coin))
        do_generate(remaining_coins, target - coin, [coin | acc], best)
    end
  end
end

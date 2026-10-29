defmodule Sieve do
  @moduledoc """
  Find prime numbers using the Sieve of Eratosthenes.
  """

  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) do
    sieve(2, limit, init_sieve(limit)) |> MapSet.to_list() |> Enum.sort()
  end

  @spec sieve(non_neg_integer, non_neg_integer, MapSet.t(non_neg_integer)) ::
          MapSet.t(non_neg_integer)
  defp sieve(x, limit, set) when x * x > limit, do: set

  defp sieve(x, limit, set),
    do: sieve(x + 1, limit, update_set(set, limit, x))

  @spec update_set(MapSet.t(non_neg_integer), non_neg_integer, non_neg_integer) ::
          MapSet.t(non_neg_integer)
  defp update_set(set, limit, x) do
    if MapSet.member?(set, x) do
      for not_prime <- (x * 2)..limit//x, reduce: set do
        acc -> MapSet.delete(acc, not_prime)
      end
    else
      set
    end
  end

  @spec init_sieve(non_neg_integer) :: MapSet.t(non_neg_integer)
  defp init_sieve(limit) do
    MapSet.new(2..limit//1)
  end
end

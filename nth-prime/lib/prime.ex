defmodule Prime do
  @moduledoc """
  Finds the nth prime number.
  """

  @doc """
  Generates the nth prime.
  """
  @spec nth(pos_integer()) :: pos_integer()
  def nth(count) when count > 0 do
    find_nth(2, :array.new(), count)
  end

  @spec find_nth(pos_integer(), :array.array(pos_integer()), pos_integer()) :: pos_integer()
  defp find_nth(candidate, primes, count) do
    size_primes = :array.size(primes)

    cond do
      not prime?(candidate, primes) ->
        find_nth(candidate + 1, primes, count)

      size_primes + 1 == count ->
        candidate

      true ->
        find_nth(candidate + 1, :array.set(size_primes, candidate, primes), count)
    end
  end

  @spec prime?(pos_integer(), :array.array(pos_integer())) :: boolean()
  defp prime?(n, primes) do
    do_prime?(n, primes, 0, :array.size(primes))
  end

  @spec do_prime?(pos_integer(), :array.array(pos_integer()), non_neg_integer(), non_neg_integer()) ::
          boolean()
  defp do_prime?(_n, _primes, index, size) when index == size, do: true

  defp do_prime?(n, primes, index, size) do
    p = :array.get(index, primes)

    cond do
      p * p > n -> true
      rem(n, p) == 0 -> false
      true -> do_prime?(n, primes, index + 1, size)
    end
  end
end

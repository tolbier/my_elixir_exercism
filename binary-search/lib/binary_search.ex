defmodule BinarySearch do
  @moduledoc """
  Search for a value in a sorted tuple using the binary search algorithm.
  """

  @doc """
    Searches for a key in the tuple using the binary search algorithm.
    It returns :not_found if the key is not in the tuple.
    Otherwise returns {:ok, index}.

    ## Examples

      iex> BinarySearch.search({}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 5)
      {:ok, 2}

  """

  @spec search(tuple, integer) :: {:ok, integer} | :not_found
  def search(numbers, key) do
    do_search(numbers, key, 0, tuple_size(numbers) - 1)
  end

  @spec do_search(tuple, integer, integer, integer) :: {:ok, integer} | :not_found
  defp do_search(_, _, low, high) when low > high, do: :not_found

  defp do_search(numbers, key, low, high) do
    mid = div(low + high, 2)

    case elem(numbers, mid) do
      ^key -> {:ok, mid}
      n when n > key -> do_search(numbers, key, low, mid - 1)
      _ -> do_search(numbers, key, mid + 1, high)
    end
  end
end

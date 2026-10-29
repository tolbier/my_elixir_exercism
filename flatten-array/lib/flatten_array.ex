defmodule FlattenArray do
  @moduledoc """
  Flattens a nested list, removing nil values.
  """

  @doc """
    Accept a list and return the list flattened without nil values.

    ## Examples

      iex> FlattenArray.flatten([1, [2], 3, nil])
      [1, 2, 3]

      iex> FlattenArray.flatten([nil, nil])
      []

  """

  @spec flatten(list) :: list
  def flatten(list) do
    do_flatten(list, [])
  end

  @spec do_flatten(term, list) :: list
  defp do_flatten([], acc), do: acc
  defp do_flatten([h | t], acc), do: do_flatten(h, do_flatten(t, acc))
  defp do_flatten(nil, acc), do: acc
  defp do_flatten(it, acc), do: [it | acc]
end

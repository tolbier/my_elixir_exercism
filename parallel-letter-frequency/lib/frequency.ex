defmodule Frequency do
  @moduledoc """
  Counts letter frequency across texts in parallel, using a fixed number of worker processes.
  """

  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map

  def frequency(texts, workers) do
    texts
    |> Task.async_stream(
      fn text ->
        text
        |> String.downcase()
        |> String.graphemes()
        |> Enum.filter(&String.match?(&1, ~r/\p{L}/u))
        |> Enum.frequencies()
      end,
      max_concurrency: workers
    )
    |> Enum.reduce(%{}, &merge_add/2)
  end

  @spec merge_add({:ok, map} | {:exit, term}, map) :: map
  defp merge_add({:ok, freq}, acc) do
    Map.merge(freq, acc, fn _key, v1, v2 -> v1 + v2 end)
  end

  defp merge_add(_, acc), do: acc
end

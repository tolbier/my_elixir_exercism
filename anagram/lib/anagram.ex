defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    low_base = base |> low
    norm_base = base |> norm

    candidates
    |> Enum.filter(fn word ->
      low_base != low(word) and norm_base == norm(word)
    end)
  end

  defp low(word) do
    word |> String.downcase()
  end

  defp norm(word) do
    word |> low |> String.graphemes() |> Enum.sort() |> Enum.join()
  end
end

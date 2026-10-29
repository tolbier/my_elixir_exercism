defmodule Pangram do
  @moduledoc """
  Determines whether a string is a pangram.
  """

  @doc """
  Determines if a word or sentence is a pangram.
  A pangram is a sentence using every letter of the alphabet at least once.

  Returns a boolean.

    ## Examples

      iex> Pangram.pangram?("the quick brown fox jumps over the lazy dog")
      true

  """

  @spec pangram?(String.t()) :: boolean
  def pangram?(sentence) do
    sentence
    |> String.downcase()
    |> String.to_charlist()
    |> MapSet.new()
    |> then(&(MapSet.new(?a..?z) |> MapSet.subset?(&1)))
  end
end

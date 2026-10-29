defmodule Scrabble do
  @moduledoc """
  Calculates the Scrabble score of a word.
  """

  @scores_src [
    {"aeioulnrst", 1},
    {"dg", 2},
    {"bcmp", 3},
    {"fhvwy", 4},
    {"k", 5},
    {"jx", 8},
    {"qz", 10}
  ]
  @scores for {letters, points} <- @scores_src,
              letter <- String.graphemes(letters),
              into: %{},
              do: {letter, points}

  @doc """
  Calculate the scrabble score for the word.
  """
  @spec score(String.t()) :: non_neg_integer
  def score(string) do
    string
    |> String.downcase()
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      acc + Map.get(@scores, char, 0)
    end)
  end
end

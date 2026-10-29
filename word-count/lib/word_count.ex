defmodule WordCount do
  @moduledoc """
  Counts how many times each word occurs in a sentence.
  """

  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    sentence
    |> String.downcase()
    |> then(&Regex.scan(~r/[a-z0-9]+(?:'[a-z0-9]+)*/, &1))
    |> List.flatten()
    |> Enum.frequencies()
  end
end

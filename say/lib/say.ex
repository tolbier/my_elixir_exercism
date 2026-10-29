defmodule Say do
  @moduledoc """
  Translates numbers into their English words representation.
  """

  @doc """
  Translate a positive integer into English.
  """
  @spec in_english(integer) :: {atom, String.t()}
  def in_english(number) when number < 0 or number >= 1_000_000_000_000,
    do: {:error, "number is out of range"}

  def in_english(number), do: {:ok, to_words(number)}

  @spec to_words(non_neg_integer) :: String.t()
  defp to_words(90), do: "ninety"
  defp to_words(80), do: "eighty"
  defp to_words(70), do: "seventy"
  defp to_words(60), do: "sixty"
  defp to_words(50), do: "fifty"
  defp to_words(40), do: "forty"
  defp to_words(30), do: "thirty"
  defp to_words(20), do: "twenty"
  defp to_words(19), do: "nineteen"
  defp to_words(18), do: "eighteen"
  defp to_words(17), do: "seventeen"
  defp to_words(16), do: "sixteen"
  defp to_words(15), do: "fifteen"
  defp to_words(14), do: "fourteen"
  defp to_words(13), do: "thirteen"
  defp to_words(12), do: "twelve"
  defp to_words(11), do: "eleven"
  defp to_words(10), do: "ten"
  defp to_words(9), do: "nine"
  defp to_words(8), do: "eight"
  defp to_words(7), do: "seven"
  defp to_words(6), do: "six"
  defp to_words(5), do: "five"
  defp to_words(4), do: "four"
  defp to_words(3), do: "three"
  defp to_words(2), do: "two"
  defp to_words(1), do: "one"
  defp to_words(0), do: "zero"

  defp to_words(n) when n >= 1_000_000_000, do: compose(n, 1_000_000_000, "billion")
  defp to_words(n) when n >= 1_000_000, do: compose(n, 1_000_000, "million")
  defp to_words(n) when n >= 1_000, do: compose(n, 1_000, "thousand")
  defp to_words(n) when n >= 100, do: compose(n, 100, "hundred")
  defp to_words(n) when n >= 10, do: compose(n, 10, "", "-")

  @spec compose(non_neg_integer, pos_integer, String.t(), String.t()) :: String.t()
  defp compose(n, bound, word, delimiter \\ " ") do
    case rem(n, bound) do
      0 -> "#{to_words(div(n, bound))} #{word}"
      rest -> "#{to_words(n - rest)}#{delimiter}#{to_words(rest)}"
    end
  end
end

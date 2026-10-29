defmodule PigLatin do
  @moduledoc """
  Translates English text to Pig Latin.
  """

  @doc """
  Given a `phrase`, translate it a word at a time to Pig Latin.
  """
  @spec translate(phrase :: String.t()) :: String.t()
  def translate(phrase) when is_binary(phrase) do
    phrase
    |> String.split()
    |> Enum.map_join(" ", &translate_word/1)
  end

  @spec translate_word(word :: String.t()) :: String.t()
  defp translate_word(word) do
    word
    |> String.to_charlist()
    |> shift()
    |> List.to_string()
    |> Kernel.<>("ay")
  end

  @spec shift(word :: charlist()) :: charlist()
  defp shift(word), do: shift(word, [])

  @spec shift(word :: charlist(), acc :: charlist()) :: charlist()
  defp shift(word = [vowel | _], acc) when vowel in ~c"aeiou", do: word ++ acc
  defp shift([?q, ?u | rest], acc), do: rest ++ acc ++ ~c"qu"
  defp shift(word = [?x, ?r | _], acc), do: word ++ acc
  defp shift(word = [?y, ?t | _], acc), do: word ++ acc
  defp shift(word = [?y | _], acc = [_ | _]), do: word ++ acc
  defp shift([consonant | rest], acc), do: shift(rest, acc ++ [consonant])
end

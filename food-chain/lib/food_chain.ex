defmodule FoodChain do
  @moduledoc """
  Generate verses of the song 'I Know an Old Lady Who Swallowed a Fly'.
  """
  @data {
    {"fly", ""},
    {"spider", "It wriggled and jiggled and tickled inside her.\n"},
    {"bird", "How absurd to swallow a bird!\n"},
    {"cat", "Imagine that, to swallow a cat!\n"},
    {"dog", "What a hog, to swallow a dog!\n"},
    {"goat", "Just opened her throat and swallowed a goat!\n"},
    {"cow", "I don't know how she swallowed a cow!\n"},
    {"horse", ""}
  }

  defguardp bird?(n) when n == 3

  @doc """
  Generate consecutive verses of the song 'I Know an Old Lady Who Swallowed a Fly'.
  """
  @spec recite(start :: integer, stop :: integer) :: String.t()
  def recite(start, stop) do
    Enum.map_join(start..stop, "\n", &verse/1)
  end

  defp verse(verse_idx) do
    first_line(verse_idx) <>
      swallow_description(verse_idx) <>
      body_lines(verse_idx) <>
      final_line(verse_idx)
  end

  defp body_lines(8), do: ""

  defp body_lines(verse_idx) do
    Enum.map_join(verse_idx..2//-1, "", &body_line/1)
  end

  defp body_line(idx) when bird?(idx),
    do: """
    #{swallow_reason(idx)} that wriggled and jiggled and tickled inside her.
    """

  defp body_line(idx),
    do: """
    #{swallow_reason(idx)}.
    """

  defp swallow_reason(idx),
    do: "She swallowed the #{animal(idx)} to catch the #{animal(idx - 1)}"

  defp first_line(verse_idx),
    do: """
    I know an old lady who swallowed a #{animal(verse_idx)}.
    """

  defp swallow_description(verse_idx) do
    @data |> elem(verse_idx - 1) |> elem(1)
  end

  defp final_line(8),
    do: """
    She's dead, of course!
    """

  defp final_line(_),
    do: """
    I don't know why she swallowed the fly. Perhaps she'll die.
    """

  defp animal(verse_idx), do: @data |> elem(verse_idx - 1) |> elem(0)
end

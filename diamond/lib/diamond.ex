defmodule Diamond do
  @moduledoc "Builds a diamond shape given a letter."

  @doc """
  Given a letter, it prints a diamond starting with 'A',
  with the supplied letter at the widest point.
  """
  @spec build_shape(char) :: String.t()
  def build_shape(last_letter) do
    upper_half = half_shape(?A..last_letter, last_letter, "")
    half_shape((last_letter - 1)..?A//-1, last_letter, upper_half)
  end

  @spec half_shape(Range.t(), char, String.t()) :: String.t()
  defp half_shape(range, last_letter, acc) do
    for letter <- range, into: acc do
      line(letter, last_letter)
    end
  end

  @spec line(char, char) :: String.t()
  defp line(letter, last_letter) do
    n = last_letter - letter
    spaces(n) <> letter_shape(letter) <> spaces(n) <> "\n"
  end

  @spec spaces(non_neg_integer) :: String.t()
  defp spaces(n), do: String.duplicate(" ", n)

  @spec letter_shape(char) :: String.t()
  defp letter_shape(?A), do: "A"

  defp letter_shape(letter) do
    n = letter - ?A
    letter_str = <<letter::utf8>>
    letter_str <> String.duplicate(" ", n * 2 - 1) <> letter_str
  end
end

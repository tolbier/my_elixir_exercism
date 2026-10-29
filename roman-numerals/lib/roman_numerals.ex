defmodule RomanNumerals do
  @moduledoc """
  Converts positive integers into Roman numerals.
  """

  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(n), do: numeral(n, "")

  @spec numeral(non_neg_integer, String.t()) :: String.t()
  defp numeral(0, acc), do: acc
  defp numeral(n, acc) when n >= 1000, do: numeral(n - 1000, acc <> "M")
  defp numeral(n, acc) when n >= 900, do: numeral(n - 900, acc <> "CM")
  defp numeral(n, acc) when n >= 500, do: numeral(n - 500, acc <> "D")
  defp numeral(n, acc) when n >= 400, do: numeral(n - 400, acc <> "CD")
  defp numeral(n, acc) when n >= 100, do: numeral(n - 100, acc <> "C")
  defp numeral(n, acc) when n >= 90, do: numeral(n - 90, acc <> "XC")
  defp numeral(n, acc) when n >= 50, do: numeral(n - 50, acc <> "L")
  defp numeral(n, acc) when n >= 40, do: numeral(n - 40, acc <> "XL")
  defp numeral(n, acc) when n >= 10, do: numeral(n - 10, acc <> "X")
  defp numeral(n, acc) when n == 9, do: numeral(n - 9, acc <> "IX")
  defp numeral(n, acc) when n >= 5, do: numeral(n - 5, acc <> "V")
  defp numeral(n, acc) when n == 4, do: numeral(n - 4, acc <> "IV")
  defp numeral(n, acc), do: numeral(n - 1, acc <> "I")
end

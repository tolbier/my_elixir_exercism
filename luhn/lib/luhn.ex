defmodule Luhn do
  @moduledoc """
  Validate numbers using the Luhn formula.
  """

  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean

  def valid?(number) do
    chars = number |> sanitize() |> String.to_charlist()

    valid_length?(chars) and
      valid_only_digits?(chars) and
      valid_credit_card_number?(chars)
  end

  @spec sanitize(String.t()) :: String.t()
  defp sanitize(str), do: str |> String.replace(" ", "")

  @spec valid_length?(charlist()) :: boolean
  defp valid_length?(chars), do: length(chars) > 1

  @spec valid_only_digits?(charlist()) :: boolean
  defp valid_only_digits?(chars),
    do: chars |> Enum.all?(&(&1 in ?0..?9))

  @spec valid_credit_card_number?(charlist()) :: boolean
  defp valid_credit_card_number?(chars) do
    chars
    |> Enum.map(&(&1 - ?0))
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn
      {digit, idx} when rem(idx, 2) == 0 -> digit
      {digit, _} -> rem(digit * 2 - 1, 9) + 1
    end)
    |> Enum.sum()
    |> then(&(rem(&1, 10) == 0))
  end
end

defmodule Isogram do
  @moduledoc """
  Determines whether a word or sentence is an isogram.
  """

  @doc """
  Determines if a word or sentence is an isogram
  """
  @spec isogram?(String.t()) :: boolean
  def isogram?(sentence) do
    sentence
    |> String.downcase()
    |> String.to_charlist()
    |> Enum.reject(&(&1 in [?-, ?\s]))
    |> Enum.frequencies()
    |> Enum.all?(fn {_char, count} -> count == 1 end)
  end
end

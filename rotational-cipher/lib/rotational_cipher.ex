defmodule RotationalCipher do
  @moduledoc """
  Implements the Caesar/ROT-N rotational cipher.
  """

  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    for <<c <- text>>, into: "", do: <<shift_char(c, shift)>>
  end

  @spec shift_char(char, shift :: integer) :: char
  defp shift_char(c, shift) when c in ?a..?z, do: rem(c - ?a + shift, 26) + ?a
  defp shift_char(c, shift) when c in ?A..?Z, do: rem(c - ?A + shift, 26) + ?A
  defp shift_char(c, _), do: c
end

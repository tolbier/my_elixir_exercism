defmodule SimpleCipher do
  @moduledoc """
  Encodes and decodes text using a Vigenère cipher with a repeating key.
  """

  @doc """
  Given a `plaintext` and `key`, encode each character of the `plaintext` by
  shifting it by the corresponding letter in the alphabet shifted by the number
  of letters represented by the `key` character, repeating the `key` if it is
  shorter than the `plaintext`.

  For example, for the letter 'd', the alphabet is rotated to become:

  defghijklmnopqrstuvwxyzabc

  You would encode the `plaintext` by taking the current letter and mapping it
  to the letter in the same position in this rotated alphabet.

  abcdefghijklmnopqrstuvwxyz
  defghijklmnopqrstuvwxyzabc

  "a" becomes "d", "t" becomes "w", etc...

  Each letter in the `plaintext` will be encoded with the alphabet of the `key`
  character in the same position. If the `key` is shorter than the `plaintext`,
  repeat the `key`.

  Example:

  plaintext = "testing"
  key = "abc"

  The key should repeat to become the same length as the text, becoming
  "abcabca". If the key is longer than the text, only use as many letters of it
  as are necessary.
  """
  @spec encode(String.t(), String.t()) :: String.t()
  def encode(plaintext, key), do: convert(plaintext, key, &(&1 - ?a))

  @doc """
  Given a `ciphertext` and `key`, decode each character of the `ciphertext` by
  finding the corresponding letter in the alphabet shifted by the number of
  letters represented by the `key` character, repeating the `key` if it is
  shorter than the `ciphertext`.

  The same rules for key length and shifted alphabets apply as in `encode/2`,
  but you will go the opposite way, so "d" becomes "a", "w" becomes "t",
  etc..., depending on how much you shift the alphabet.
  """
  @spec decode(String.t(), String.t()) :: String.t()
  def decode(ciphertext, key), do: convert(ciphertext, key, &(?a - &1))

  @doc """
  Generate a random key of a given length. It should contain lowercase letters only.
  """
  @spec generate_key(pos_integer) :: String.t()
  def generate_key(length),
    do:
      1..length
      |> Enum.map(fn _ -> Enum.random(?a..?z) end)
      |> List.to_string()

  @spec convert(String.t(), String.t(), (char -> integer)) :: String.t()
  defp convert(text, key, func),
    do:
      text
      |> String.to_charlist()
      |> Enum.zip(key |> String.to_charlist() |> Stream.cycle())
      |> Enum.map(fn {char, key_char} -> shift(char, func.(key_char)) end)
      |> List.to_string()

  @spec shift(char, integer) :: char
  defp shift(char, offset), do: Integer.mod(char - ?a + offset, 26) + ?a
end

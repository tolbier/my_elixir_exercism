defmodule Atbash do
  @moduledoc """
  Encode and decode text using the Atbash cipher.
  """

  @doc """
  Encode a given plaintext to the corresponding ciphertext

  ## Examples

  iex> Atbash.encode("completely insecure")
  "xlnko vgvob rmhvx fiv"
  """
  @spec encode(String.t()) :: String.t()
  def encode(plaintext) do
    plaintext
    |> convert()
    |> Enum.chunk_every(5)
    |> Enum.map_join(" ", &List.to_string/1)
  end

  @spec decode(String.t()) :: String.t()
  def decode(cipher) do
    cipher
    |> convert()
    |> List.to_string()
  end

  @spec convert(String.t()) :: [char()]
  defp convert(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^0-9a-zA-Z]/, "")
    |> String.to_charlist()
    |> Enum.map(&convert_char/1)
  end

  @spec convert_char(char()) :: char()
  defp convert_char(c) when c in ?a..?z, do: ?z + ?a - c
  defp convert_char(c), do: c
end

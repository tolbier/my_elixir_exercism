defmodule AffineCipher do
  @moduledoc """
  Encodes and decodes messages using the affine cipher.
  """

  @typedoc """
  A type for the encryption key
  """
  @type key() :: %{a: integer, b: integer}

  @alphabet_length ?z - ?a + 1
  @doc """
  Encode an encrypted message using a key
  """
  @spec encode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(key, message) do
    crypt(key, message, &encode_char/2, " ")
  end

  @doc """
  Decode an encrypted message using a key
  """
  @spec decode(key :: key(), encrypted :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(key, encrypted) do
    crypt(key, encrypted, &decode_char/2)
  end

  @spec crypt(key(), String.t(), (key(), char -> char), String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  defp crypt(key = %{a: a}, str, crypt_fun, joiner \\ "") do
    if coprime?(a, @alphabet_length) do
      {:ok,
       str
       |> String.downcase()
       |> String.to_charlist()
       |> Enum.filter(&(&1 in ?a..?z or &1 in ?0..?9))
       |> Enum.map(&crypt_fun.(key, &1))
       |> Enum.chunk_every(5)
       |> Enum.map_join(joiner, &List.to_string/1)}
    else
      {:error, "a and m must be coprime."}
    end
  end

  @spec encode_char(key(), char) :: char
  defp encode_char(%{a: a, b: b}, char) when char in ?a..?z,
    do: Integer.mod((char - ?a) * a + b, @alphabet_length) + ?a

  defp encode_char(_, char), do: char

  @spec decode_char(key(), char) :: char
  defp decode_char(%{a: a, b: b}, char) when char in ?a..?z,
    do: Integer.mod(mmi(a) * (char - ?a - b), @alphabet_length) + ?a

  defp decode_char(_, char), do: char

  @spec mmi(integer) :: pos_integer | nil
  defp mmi(a),
    do: Enum.find(1..@alphabet_length, fn n -> Integer.mod(a * n, @alphabet_length) == 1 end)

  @spec coprime?(integer, integer) :: boolean
  defp coprime?(a, b), do: Integer.gcd(a, b) == 1
end

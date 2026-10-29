defmodule CryptoSquare do
  @moduledoc """
  Encodes plaintext using the square code method.
  """

  @doc """
  Encode string square methods
  ## Examples

    iex> CryptoSquare.encode("abcd")
    "ac bd"
  """
  @spec encode(String.t()) :: String.t()
  def encode(str), do: str |> normalize |> do_encode

  @spec do_encode(String.t()) :: String.t()
  defp do_encode(str) when str == "", do: ""

  defp do_encode(str) do
    c = square_size(str)

    str
    |> String.to_charlist()
    |> Enum.chunk_every(c, c, Stream.cycle([?\s]))
    |> Enum.zip_with(& &1)
    |> Enum.map_join(" ", &List.to_string/1)
  end

  @spec normalize(String.t()) :: String.t()
  defp normalize(str) do
    str
    |> String.downcase()
    |> String.to_charlist()
    |> Enum.filter(&alphanumeric?/1)
    |> List.to_string()
  end

  @spec alphanumeric?(char) :: boolean
  defp alphanumeric?(c), do: c in ?a..?z or c in ?0..?9

  @spec square_size(String.t()) :: pos_integer
  defp square_size(str) do
    l = String.length(str)
    r = l |> :math.sqrt() |> trunc()
    if r ** 2 != l, do: r + 1, else: r
  end
end

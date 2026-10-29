defmodule RailFenceCipher do
  @moduledoc """
  Encodes and decodes text using the rail fence cipher.
  """

  @doc """
  Encode a given plaintext to the corresponding rail fence ciphertext
  """
  @spec encode(String.t(), pos_integer) :: String.t()
  def encode(str, 1), do: str

  def encode(str, n_rails) do
    do_encode(String.graphemes(str), 0, n_rails, List.duplicate([], n_rails))
    |> Enum.map_join(fn rail -> rail |> Enum.reverse() |> Enum.join() end)
  end

  @spec do_encode([String.t()], non_neg_integer(), pos_integer(), [[String.t()]]) :: [
          [String.t()]
        ]
  defp do_encode([], _i, _n_rails, rails), do: rails

  defp do_encode([first | rest], i, n_rails, rails) do
    rail_pos = rail_pos(i, n_rails)
    next_rails = List.update_at(rails, rail_pos, fn rail -> [first | rail] end)
    do_encode(rest, i + 1, n_rails, next_rails)
  end

  @spec rail_pos(non_neg_integer(), pos_integer()) :: non_neg_integer()
  defp rail_pos(i, n_rails) do
    period = 2 * (n_rails - 1)
    position = rem(i, period)
    min(position, period - position)
  end

  @doc """
  Decode a given rail fence ciphertext to the corresponding plaintext
  """
  @spec decode(String.t(), pos_integer) :: String.t()
  def decode(str, 1), do: str
  def decode("", _n_rails), do: ""

  def decode(str, n_rails) do
    chars = String.graphemes(str)
    size = length(chars)

    counts = rail_counts(size, n_rails)
    rails = split_rails(counts, chars)

    do_decode(rails, 0, [], size)
  end

  @spec split_rails([non_neg_integer()], [String.t()]) :: [[String.t()]]
  defp split_rails(counts, chars) do
    {rails, []} =
      Enum.map_reduce(counts, chars, fn count, remaining ->
        Enum.split(remaining, count)
      end)

    rails
  end

  @spec frequencies(pos_integer(), pos_integer()) :: %{non_neg_integer() => pos_integer()}
  defp frequencies(size, n_rails) do
    0..(size - 1)
    |> Enum.map(fn i -> rail_pos(i, n_rails) end)
    |> Enum.frequencies()
  end

  @spec rail_counts(pos_integer(), pos_integer()) :: [non_neg_integer()]
  defp rail_counts(size, n_rails) do
    frequencies = frequencies(size, n_rails)

    Enum.map(0..(n_rails - 1), fn rail ->
      Map.get(frequencies, rail, 0)
    end)
  end

  @spec do_decode([[String.t()]], non_neg_integer(), [String.t()], non_neg_integer()) ::
          String.t()
  defp do_decode(_rails, position, acc, position) do
    acc |> Enum.reverse() |> Enum.join()
  end

  defp do_decode(rails, position, acc, size) do
    rail = rail_pos(position, length(rails))
    [character | rest] = Enum.at(rails, rail)
    next_rails = List.replace_at(rails, rail, rest)
    do_decode(next_rails, position + 1, [character | acc], size)
  end
end

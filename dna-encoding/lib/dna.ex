defmodule DNA do
  @nucleotides %{?\s => 0b0000, ?A => 0b0001, ?C => 0b0010, ?G => 0b0100, ?T => 0b1000}
  @codes Map.new(@nucleotides, fn {char, code} -> {code, char} end)
  @code_size 4

  def encode_nucleotide(char), do: Map.fetch!(@nucleotides, char)

  def decode_nucleotide(code), do: Map.fetch!(@codes, code)

  def encode(dna), do: do_encode(dna, <<>>)
  defp do_encode([], acc), do: acc

  defp do_encode(_dna = [h | t], acc),
    do: do_encode(t, <<acc::bitstring, encode_nucleotide(h)::@code_size>>)

  def decode(dna_bs), do: do_decode(dna_bs, []) |> reverse()
  defp do_decode(<<>>, acc), do: acc

  defp do_decode(<<value::@code_size, rest::bitstring>>, acc),
    do: do_decode(rest, [decode_nucleotide(value) | acc])

  defp reverse(list), do: reverse(list, [])
  defp reverse([], acc), do: acc
  defp reverse([h | t], acc), do: reverse(t, [h | acc])
end

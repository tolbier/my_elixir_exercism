defmodule VariableLengthQuantity do
  @moduledoc "Encodes and decodes integers using variable-length quantities."

  @doc """
  Encode integers into a bitstring of VLQ encoded bytes
  """
  @spec encode(integers :: [0..0xFFFFFFFF]) :: binary()
  def encode(integers) do
    Enum.map_join(integers, fn integer ->
      encode(<<integer::32>>, 0)
    end)
  end

  @spec encode(<<_::32>>, 0..1) :: binary()
  defp encode(<<0::25, value::7>>, continuation_bit) do
    <<continuation_bit::1, value::7>>
  end

  defp encode(<<rest::25, last_seven::7>>, continuation_bit) do
    <<encode(<<rest::32>>, 1)::binary, continuation_bit::1, last_seven::7>>
  end

  @doc """
  Decode a bitstring of VLQ encoded bytes into a series of integers
  """
  @spec decode(bytes :: binary()) :: {:ok, [non_neg_integer()]} | {:error, String.t()}
  def decode(bytes) do
    decode(bytes, 0, [])
  end

  @spec decode(binary(), non_neg_integer(), [non_neg_integer()]) ::
          {:ok, [non_neg_integer()]} | {:error, String.t()}
  defp decode(<<>>, _integer, acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp decode(<<1::1, _value::7>>, _integer, _acc) do
    {:error, "incomplete sequence"}
  end

  defp decode(<<1::1, value::7, rest::binary>>, integer, acc) do
    decode(rest, integer * 128 + value, acc)
  end

  defp decode(<<0::1, value::7, rest::binary>>, integer, acc) do
    decode(rest, 0, [integer * 128 + value | acc])
  end
end

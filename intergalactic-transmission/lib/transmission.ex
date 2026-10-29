defmodule Transmission do
  @moduledoc """
  Encode and decode intergalactic transmissions.
  """

  @doc """
  Return the transmission sequence for a message.
  """
  @spec get_transmit_sequence(binary()) :: binary()
  def get_transmit_sequence(message) do
    do_get_transmit_sequence(message, <<>>)
  end

  defp do_get_transmit_sequence(<<first_seven::size(7), rest::bitstring>>, acc) do
    do_get_transmit_sequence(
      rest,
      <<acc::bitstring, parity_checked(<<first_seven::size(7)>>)::bitstring>>
    )
  end

  defp do_get_transmit_sequence(<<>>, acc), do: acc

  defp do_get_transmit_sequence(<<last::bitstring>>, acc) do
    zero_pad_size = 7 - bit_size(last)
    <<acc::bitstring, parity_checked(<<last::bitstring, 0::size(zero_pad_size)>>)::bitstring>>
  end

  @spec parity_checked(bitstring()) :: bitstring()
  defp parity_checked(bits) do
    <<bits::bitstring, parity_bit(bits)::size(1)>>
  end

  @spec parity_bit(bitstring()) :: 0 | 1
  defp parity_bit(bits) do
    bits |> count_ones() |> rem(2)
  end

  @spec count_ones(bitstring()) :: non_neg_integer()
  defp count_ones(bits) do
    for <<bit::size(1) <- bits>>, reduce: 0 do
      acc -> acc + bit
    end
  end

  @doc """
  Return the message decoded from the received transmission.
  """
  @spec decode_message(binary()) :: {:ok, binary()} | {:error, String.t()}
  def decode_message(received_data) do
    do_decode_message(received_data, <<>>)
  end

  defp do_decode_message(<<first_seven::size(7), parity::size(1), rest::bitstring>>, acc) do
    case parity_bit(<<first_seven::size(7)>>) do
      ^parity ->
        do_decode_message(
          rest,
          <<acc::bitstring, first_seven::size(7)>>
        )

      _ ->
        {:error, "wrong parity"}
    end
  end

  defp do_decode_message(<<>>, acc) do
    trunc_size = div(bit_size(acc), 8) * 8
    {:ok, <<acc::bitstring-size(trunc_size)>>}
  end
end

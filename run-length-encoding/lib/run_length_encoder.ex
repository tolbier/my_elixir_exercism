defmodule RunLengthEncoder do
  @moduledoc """
  Encodes and decodes strings using run-length encoding.
  """

  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "AABBBCCCC" => "2A3B4C"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "2A3B4C" => "AABBBCCCC"
  """
  @spec encode(String.t()) :: String.t()
  def encode(string),
    do:
      string
      |> String.to_charlist()
      |> encode({0, nil}, "")

  @spec encode(charlist, {non_neg_integer, char | nil}, String.t()) :: String.t()
  defp encode([], block_acc = {_n, _acc_char}, acc), do: acc <> encode_chars(block_acc)

  defp encode([c | tail], block_acc = {_n, acc_char}, acc) when c != acc_char do
    encode(tail, {1, c}, acc <> encode_chars(block_acc))
  end

  defp encode([c | tail], _block_acc = {n, _acc_char}, acc) do
    encode(tail, {n + 1, c}, acc)
  end

  @spec encode_chars({non_neg_integer, char | nil}) :: String.t()
  defp encode_chars({0, _}), do: ""
  defp encode_chars({1, acc_char}), do: <<acc_char::utf8>>
  defp encode_chars({n, acc_char}), do: "#{n}#{<<acc_char::utf8>>}"

  @spec decode(String.t()) :: String.t()
  def decode(string) do
    ~r/\d*[A-Za-z ]/
    |> Regex.scan(string)
    |> List.flatten()
    |> Enum.map_join(fn group ->
      {count, char} =
        case Integer.parse(group) do
          {n, rest} -> {n, rest}
          :error -> {1, group}
        end

      String.duplicate(char, count)
    end)
  end
end

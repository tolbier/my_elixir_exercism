defmodule SecretHandshake do
  @moduledoc """
  Determines the secret handshake actions from a numeric code.
  """

  @actions ["jump", "close your eyes", "double blink", "wink"]

  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    collect_and_reverse(<<code::size(5)>>, @actions, [])
  end

  @spec collect_and_reverse(bitstring, list(String.t()), list(String.t())) :: list(String.t())
  defp collect_and_reverse(<<1::1, rest::bitstring>>, actions, acc) do
    collect(rest, actions, acc) |> Enum.reverse()
  end

  defp collect_and_reverse(<<0::1, rest::bitstring>>, actions, acc) do
    collect(rest, actions, acc)
  end

  @spec collect(bitstring, list(String.t()), list(String.t())) :: list(String.t())
  defp collect(<<>>, _actions, acc), do: acc

  defp collect(<<1::1, rest::bitstring>>, [action | rest_actions], acc) do
    collect(rest, rest_actions, [action | acc])
  end

  defp collect(<<0::1, rest::bitstring>>, [_ | rest_actions], acc) do
    collect(rest, rest_actions, acc)
  end
end

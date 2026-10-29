defmodule Bob do
  @moduledoc """
  Determine Bob's response to a remark.
  """

  @spec hey(String.t()) :: String.t()
  def hey(input) do
    str = String.replace(input, ~r/[^\p{L}0-9?]/u, "")
    do_hey(str)
  end

  @spec do_hey(String.t()) :: String.t()
  defp do_hey(str) when byte_size(str) == 0, do: "Fine. Be that way!"

  defp do_hey(str) do
    case {shouting?(str), question?(str)} do
      {true, true} -> "Calm down, I know what I'm doing!"
      {true, false} -> "Whoa, chill out!"
      {false, true} -> "Sure."
      {false, false} -> "Whatever."
    end
  end

  @spec question?(String.t()) :: boolean
  defp question?(str), do: String.match?(str, ~r/\?$/)

  @spec shouting?(String.t()) :: boolean
  defp shouting?(str), do: String.match?(str, ~r/^(?=.*\p{Lu})[^\p{Ll}]*$/u)
end

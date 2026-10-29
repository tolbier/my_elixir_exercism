defmodule MatchingBrackets do
  @moduledoc """
  Checks whether all brackets, braces, and parentheses in a string are matched and correctly nested.
  """
  @openers %{?( => ?), ?[ => ?], ?{ => ?}}
  @closers [?), ?], ?}]
  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce_while([], &match_char/2)
    |> case do
      [] -> true
      _ -> false
    end
  end

  @spec match_char(char, charlist) :: {:cont, charlist} | {:halt, :error}
  defp match_char(char, stack) when is_map_key(@openers, char) do
    {:cont, [@openers[char] | stack]}
  end

  defp match_char(char, [char | rest]) when char in @closers, do: {:cont, rest}
  defp match_char(char, _stack) when char in @closers, do: {:halt, :error}
  defp match_char(_char, stack), do: {:cont, stack}
end

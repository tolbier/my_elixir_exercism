defmodule Proverb do
  @moduledoc """
  Generates the "For Want of a Nail" proverb from a list of items.
  """

  @doc """
  Generate a proverb from a list of strings.
  """
  @spec recite(strings :: [String.t()]) :: String.t()
  def recite([]), do: ""
  def recite(strings = [initial | _rest]), do: do_recite(strings, initial, "")

  @spec do_recite([String.t()], String.t(), String.t()) :: String.t()
  defp do_recite([_it], initial, acc), do: acc <> "And all for the want of a #{initial}.\n"

  defp do_recite([first | rest = [second | _]], initial, acc),
    do: do_recite(rest, initial, acc <> "For want of a #{first} the #{second} was lost.\n")
end

defmodule Sublist do
  @moduledoc """
  Compares two lists to determine if one is equal, a sublist, a superlist,
  or unequal to the other.
  """

  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  @spec compare(list(any), list(any)) :: :equal | :sublist | :superlist | :unequal
  def compare(a, b) do
    cond do
      a == b -> :equal
      contains?(a, b) -> :sublist
      contains?(b, a) -> :superlist
      true -> :unequal
    end
  end

  @spec contains?(list(any), list(any)) :: boolean
  defp contains?(_a, []), do: false
  defp contains?(a, b = [_ | t_b]), do: starts_with?(a, b) or contains?(a, t_b)

  @spec starts_with?(list(any), list(any)) :: boolean
  defp starts_with?([], _), do: true
  defp starts_with?([h_a | t_a], [h_b | t_b]) when h_a === h_b, do: starts_with?(t_a, t_b)
  defp starts_with?(_, _), do: false
end

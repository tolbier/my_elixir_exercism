defmodule SquareRoot do
  @moduledoc """
  Calculate the integer square root of a positive integer.
  """

  @doc """
  Calculate the integer square root of a positive integer
  """
  @spec calculate(radicand :: pos_integer) :: pos_integer
  def calculate(radicand) do
    calculate(radicand, 1)
  end

  defguardp squared_exceeds?(x, limit) when x * x > limit

  @spec calculate(pos_integer, pos_integer) :: pos_integer
  defp calculate(radicand, root) when squared_exceeds?(root + 1, radicand), do: root
  defp calculate(radicand, root), do: calculate(radicand, root + 1)
end

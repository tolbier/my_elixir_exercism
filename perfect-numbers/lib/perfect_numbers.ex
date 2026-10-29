defmodule PerfectNumbers do
  @moduledoc """
  Classifies numbers as perfect, abundant, or deficient based on their aliquot sum.
  """

  @doc """
  Determine the aliquot sum of the given `number`, by summing all the factors
  of `number`, aside from `number` itself.

  Based on this sum, classify the number as:

  :perfect if the aliquot sum is equal to `number`
  :abundant if the aliquot sum is greater than `number`
  :deficient if the aliquot sum is less than `number`
  """
  @spec classify(number :: integer) :: {:ok, atom} | {:error, String.t()}
  def classify(number) when number <= 0,
    do: {:error, "Classification is only possible for natural numbers."}

  def classify(number) do
    {:ok,
     case aliquot_sum(number) - number do
       0 -> :perfect
       n when n < 0 -> :deficient
       _ -> :abundant
     end}
  end

  @spec aliquot_sum(pos_integer) :: non_neg_integer
  defp aliquot_sum(number) do
    1..div(number, 2)//1
    |> Enum.filter(fn x -> rem(number, x) == 0 end)
    |> Enum.sum()
  end
end

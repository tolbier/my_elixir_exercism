defmodule Hamming do
  @moduledoc """
  Calculates the Hamming distance between two DNA strands.
  """

  @doc """
  Returns number of differences between two strands of DNA, known as the Hamming Distance.

  ## Examples

  iex> Hamming.hamming_distance(~c"AAGTCATA", ~c"TAGCGATC")
  {:ok, 4}
  """
  @spec hamming_distance([char], [char]) :: {:ok, non_neg_integer} | {:error, String.t()}
  def hamming_distance(strand1, strand2) do
    count(strand1, strand2, 0)
  end

  @spec count([char], [char], non_neg_integer) :: {:ok, non_neg_integer} | {:error, String.t()}
  defp count([], [], acc), do: {:ok, acc}

  defp count([], _, _), do: error()
  defp count(_, [], _), do: error()

  defp count([h1 | t1], [h2 | t2], acc) do
    count(t1, t2, acc + eval(h1, h2))
  end

  @spec eval(char, char) :: 0 | 1
  defp eval(a, b) when a == b, do: 0
  defp eval(_a, _b), do: 1

  @spec error() :: {:error, String.t()}
  defp error(), do: {:error, "strands must be of equal length"}
end

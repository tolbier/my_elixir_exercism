defmodule Darts do
  @moduledoc """
  Calculates dart game scores based on where a dart lands on the target.
  """

  @type position :: {number, number}

  @doc """
  Calculate the score of a single dart hitting a target
  """
  @spec score(position) :: integer
  def score(coords = {_, _}) do
    dist = distance(coords)

    cond do
      dist > 10 -> 0
      dist > 5 -> 1
      dist > 1 -> 5
      true -> 10
    end
  end

  @spec distance(position) :: float
  defp distance({x, y}), do: :math.sqrt(:math.pow(x, 2) + :math.pow(y, 2))
end

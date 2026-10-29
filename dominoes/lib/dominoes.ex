defmodule Dominoes do
  @moduledoc """
  Determines whether a set of domino stones can be arranged into a closed chain.
  """

  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino]) :: boolean
  def chain?([]), do: true

  def chain?(list = [{a, _} | _]) do
    list
    |> loop_chain?(a, a)
  end

  @spec loop_chain?([domino], 1..6, 1..6) :: boolean
  defp loop_chain?([{last, loop_begin}], last, loop_begin), do: true
  defp loop_chain?([{loop_begin, last}], last, loop_begin), do: true

  defp loop_chain?([{a1, last} | rest], last, loop_begin),
    do: chain_on_rest?(rest, a1, loop_begin)

  defp loop_chain?([{last, b1} | rest], last, loop_begin),
    do: chain_on_rest?(rest, b1, loop_begin)

  defp loop_chain?(_, _, _), do: false

  @spec chain_on_rest?([domino], 1..6, 1..6) :: boolean
  defp chain_on_rest?(rest, last, loop_begin) do
    rest
    |> picks()
    |> Enum.any?(fn rest_pick -> loop_chain?(rest_pick, last, loop_begin) end)
  end

  @spec picks([domino], [domino]) :: [[domino]]
  defp picks(list, seen \\ [])
  defp picks([], _seen), do: []
  defp picks([h | t], seen), do: [[h | seen ++ t] | picks(t, [h | seen])]
end

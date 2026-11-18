defmodule GoCounting do
  @moduledoc """
  Counts the territory owned by each player on a Go board.
  """

  @type position :: {x :: integer, y :: integer}
  @type owner :: :white | :black | :none
  @type territory :: %{owner: owner(), territory: [position()]}
  @type territories :: %{white: [position()], black: [position()], none: [position()]}

  @typep stone :: :white | :black
  # Every position of the board is a key, so a missing key is outside the board
  @typep board :: %{position() => stone() | :empty}
  @typep visited :: MapSet.t(position())

  @cells %{"B" => :black, "W" => :white, "_" => :empty}
  @owners [:white, :black, :none]

  @doc """
  Return the owner and territory around a position
  """
  @spec territory(board_str :: String.t(), position :: position()) ::
          {:ok, territory()} | {:error, String.t()}
  def territory(board_str, position) do
    board = parse(board_str)

    case board[position] do
      nil -> {:error, "Invalid coordinate"}
      :empty -> {:ok, find_territory(board, position)}
      # A stone is never territory, whatever its colour
      _stone -> {:ok, %{owner: :none, territory: []}}
    end
  end

  @doc """
  Return all white, black and neutral territories
  """
  @spec territories(board_str :: String.t()) :: territories()
  def territories(board_str) do
    board = parse(board_str)
    empty_positions = for {position, :empty} <- board, do: position

    empty_positions
    |> find_territories(board)
    |> group_by_owner()
  end

  @spec parse(String.t()) :: board()
  defp parse(board_str) do
    for {row, y} <- board_str |> String.split("\n", trim: true) |> Enum.with_index(),
        {char, x} <- row |> String.graphemes() |> Enum.with_index(),
        into: %{},
        do: {{x, y}, Map.fetch!(@cells, char)}
  end

  # Each territory is filled from its first unvisited position; its positions
  # are then removed so no territory is found twice
  @spec find_territories([position()], board()) :: [territory()]
  defp find_territories([], _board), do: []

  defp find_territories([position | unvisited], board) do
    territory = find_territory(board, position)
    [territory | find_territories(unvisited -- territory.territory, board)]
  end

  @spec group_by_owner([territory()]) :: territories()
  defp group_by_owner(territories), do: Map.new(@owners, &{&1, owned_positions(territories, &1)})

  @spec owned_positions([territory()], owner()) :: [position()]
  defp owned_positions(territories, owner) do
    positions = for %{owner: ^owner, territory: territory} <- territories, do: territory
    positions |> Enum.concat() |> Enum.sort()
  end

  # Flood fill over the empty positions connected to start, collecting the
  # colours of the stones that border them
  @spec find_territory(board(), position()) :: territory()
  defp find_territory(board, start) do
    pending = neighbours(board, start)
    {territory, border_colours} = explore(pending, board, MapSet.new([start]), [])
    %{owner: owner(border_colours), territory: Enum.sort(territory)}
  end

  # pending holds the positions still to visit: an empty one joins the territory
  # and adds its neighbours, a stone only adds its colour to the border
  @spec explore([position()], board(), visited(), [stone()]) :: {visited(), [stone()]}
  defp explore([], _board, territory, border_colours), do: {territory, border_colours}

  defp explore([position | pending], board, territory, border_colours) do
    cond do
      MapSet.member?(territory, position) ->
        explore(pending, board, territory, border_colours)

      board[position] == :empty ->
        pending = neighbours(board, position) ++ pending
        explore(pending, board, MapSet.put(territory, position), border_colours)

      true ->
        explore(pending, board, territory, [board[position] | border_colours])
    end
  end

  # Only horizontal and vertical neighbours inside the board
  @spec neighbours(board(), position()) :: [position()]
  defp neighbours(board, {x, y}),
    do: Enum.filter([{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}], &Map.has_key?(board, &1))

  # A territory belongs to a player only if all its border stones are theirs
  @spec owner([stone()]) :: owner()
  defp owner(border_colours) do
    case Enum.uniq(border_colours) do
      [colour] -> colour
      _no_or_both_colours -> :none
    end
  end
end

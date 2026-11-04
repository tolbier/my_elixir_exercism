defmodule Connect do
  @moduledoc """
  Determines the winner of a Connect board.
  """
  defstruct board: %{}, width: 0, height: 0

  @type player :: :X | :O
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @type t :: %__MODULE__{
          board: %{coord() => player()},
          width: non_neg_integer(),
          height: non_neg_integer()
        }

  @doc """
  Calculates the winner (if any) of a board
  """
  @spec result_for([String.t()]) :: :none | player()
  def result_for(str_list) do
    parse_board(str_list)
    |> determine_winner
  end

  @spec determine_winner(t()) :: :none | player()
  defp determine_winner(connect) do
    cond do
      win?(connect, :X) -> :X
      win?(connect, :O) -> :O
      true -> :none
    end
  end

  @spec win?(t(), player()) :: boolean()
  defp win?(connect, player) do
    connect
    |> starting_cells(player)
    |> path_to_goal?(connect, player, MapSet.new())
  end

  @spec path_to_goal?([coord()], t(), player(), MapSet.t(coord())) :: boolean()
  defp path_to_goal?([], _connect, _player, _visited), do: false

  defp path_to_goal?([coords | rest], connect, player, visited) do
    cond do
      goal_reached?(connect, coords, player) ->
        true

      MapSet.member?(visited, coords) ->
        path_to_goal?(rest, connect, player, visited)

      true ->
        pending = player_neighbors(connect, coords, player) ++ rest
        visited = MapSet.put(visited, coords)
        path_to_goal?(pending, connect, player, visited)
    end
  end

  @spec starting_cells(t(), player()) :: [coord()]
  defp starting_cells(connect, player) do
    first_coords(connect, player)
    |> filter_player_coords(connect, player)
  end

  @spec first_coords(t(), player()) :: [coord()]
  defp first_coords(connect, :X) do
    edge_coords(connect.height, &{0, &1})
  end

  defp first_coords(connect, :O) do
    edge_coords(connect.width, &{&1, 0})
  end

  @spec edge_coords(non_neg_integer(), (non_neg_integer() -> coord())) :: [coord()]
  defp edge_coords(limit, mapper) when limit > 0 do
    0..(limit - 1)
    |> Enum.map(mapper)
  end

  defp edge_coords(_limit, _mapper), do: []

  @spec goal_reached?(t(), coord(), player()) :: boolean()
  defp goal_reached?(%{width: width}, {x, _y}, :X), do: x == width - 1
  defp goal_reached?(%{height: height}, {_x, y}, :O), do: y == height - 1

  @doc """
  Returns adjacent coordinates occupied by the given player.
  """
  @spec player_neighbors(t(), coord(), player()) :: [coord()]
  def player_neighbors(connect, coords, player)
      when player in [:X, :O] do
    coords
    |> neighbor_coords()
    |> filter_player_coords(connect, player)
  end

  @spec filter_player_coords([{integer(), integer()}], t(), player()) :: [coord()]
  defp filter_player_coords(coords, %__MODULE__{board: board}, player) do
    Enum.filter(coords, fn coord -> Map.get(board, coord) == player end)
  end

  # Returns the six adjacent hexagonal coordinates, without checking board boundaries.
  @spec neighbor_coords({integer(), integer()}) :: [{integer(), integer()}]
  defp neighbor_coords({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x, y + 1}
    ]
  end

  @doc """
  Converts rows into a Connect struct, with zero-based {column, row} coordinates.
  Empty cells are omitted from the board map, but still count toward its dimensions.
  """
  @spec parse_board([String.t()]) :: t()
  def parse_board(str_list) do
    board =
      for {row, y} <- Enum.with_index(str_list),
          {cell, x} <- Enum.with_index(String.graphemes(row)),
          cell != ".",
          into: %{} do
        value =
          case cell do
            "X" -> :X
            "O" -> :O
          end

        {{x, y}, value}
      end

    %__MODULE__{
      board: board,
      width: String.length(List.first(str_list) || ""),
      height: length(str_list)
    }
  end
end

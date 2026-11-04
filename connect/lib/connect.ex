defmodule Connect do
  @moduledoc """
  Determines the winner of a Connect board.
  """
  defstruct board: %{}, width: 0, height: 0

  @type t :: %__MODULE__{
          board: %{{non_neg_integer(), non_neg_integer()} => :X | :O},
          width: non_neg_integer(),
          height: non_neg_integer()
        }

  @doc """
  Calculates the winner (if any) of a board
  """
  @spec result_for([String.t()]) :: :none | :X | :O
  def result_for(str_list) do
    str_list_to_connect(str_list)
    |> determine_winner
  end

  defp determine_winner(connect) do
    cond do
      win?(connect, :X) -> :X
      win?(connect, :O) -> :O
      true -> :none
    end
  end

  defp win?(connect, player) do
    connect
    |> first_player_lane(player)
    |> Enum.any?(&win_cell?(connect, player, &1, MapSet.new()))
  end

  defp win_cell?(connect, player, coords, visited) do
    cond do
      MapSet.member?(visited, coords) ->
        false

      goal_reached?(connect, coords, player) ->
        true

      true ->
        visited = MapSet.put(visited, coords)

        player_neighbors(connect, coords, player)
        |> Enum.any?(&win_cell?(connect, player, &1, visited))
    end
  end

  defp first_player_lane(connect, player) do
    first_coords(connect, player)
    |> filter_player_coords(connect, player)
  end

  defp first_coords(connect, :X) do
    first_coords(connect.height, &{0, &1})
  end

  defp first_coords(connect, :O) do
    first_coords(connect.width, &{&1, 0})
  end

  defp first_coords(limit, mapper) do
    0..(limit - 1)
    |> Enum.map(mapper)
  end

  defp goal_reached?(_connect = %{width: width}, {x, _y}, :X) when x == width - 1, do: true
  defp goal_reached?(_connect = %{height: height}, {_x, y}, :O) when y == height - 1, do: true
  defp goal_reached?(_connect, {_x, _y}, _player), do: false

  @doc """
  Returns adjacent coordinates occupied by the given player.
  """
  @spec player_neighbors(t(), {non_neg_integer(), non_neg_integer()}, :X | :O) ::
          [{non_neg_integer(), non_neg_integer()}]
  def player_neighbors(connect, coords, player)
      when player in [:X, :O] do
    coords
    |> neighbour_coords()
    |> filter_player_coords(connect, player)
  end

  @spec filter_player_coords([{integer(), integer()}], map(), :X | :O) ::
          [{non_neg_integer(), non_neg_integer()}]
  defp filter_player_coords(coords, %__MODULE__{board: board}, player) do
    Enum.filter(coords, fn coord -> Map.get(board, coord) == player end)
  end

  # Returns the six adjacent hexagonal coordinates, without checking board boundaries.
  @spec neighbour_coords({integer(), integer()}) :: [{integer(), integer()}]
  defp neighbour_coords({x, y}) do
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
  @spec str_list_to_connect([String.t()]) :: t()
  def str_list_to_connect(str_list) do
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

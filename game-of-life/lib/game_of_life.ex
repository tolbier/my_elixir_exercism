defmodule GameOfLife do
  @moduledoc "Implements Conway's Game of Life."

  defmodule Matrix do
    @moduledoc "Represents a Game of Life matrix."

    @type coords :: {non_neg_integer(), non_neg_integer()}

    @type t :: %__MODULE__{
            width: non_neg_integer(),
            height: non_neg_integer(),
            live_cells: MapSet.t(coords())
          }
    defstruct width: 0, height: 0, live_cells: MapSet.new()

    @spec new(list(list(0 | 1))) :: t()
    def new(rows) do
      %__MODULE__{
        width: rows |> List.first([]) |> length(),
        height: length(rows),
        live_cells:
          for {row, y} <- Enum.with_index(rows),
              {cell, x} <- Enum.with_index(row),
              cell == 1,
              into: MapSet.new() do
            {x, y}
          end
      }
    end

    @spec cells(t(), :live | :dead) :: list(coords())
    def cells(%__MODULE__{live_cells: live_cells}, :live) do
      Enum.sort_by(live_cells, fn {x, y} -> {y, x} end)
    end

    def cells(%__MODULE__{width: width, height: height, live_cells: live_cells}, :dead) do
      for y <- 0..(height - 1)//1,
          x <- 0..(width - 1)//1,
          cell_value(live_cells, {x, y}) == 0 do
        {x, y}
      end
    end

    @spec tick(t()) :: t()
    def tick(%__MODULE__{live_cells: live_cells} = matrix) do
      neighbour_counts =
        Enum.reduce(live_cells, %{}, fn coords, counts ->
          Enum.reduce(neighbours(matrix, coords), counts, fn neighbour, counts ->
            Map.update(counts, neighbour, 1, &(&1 + 1))
          end)
        end)

      next_live_cells =
        for {coords, count} <- neighbour_counts,
            count == 3 or (count == 2 and MapSet.member?(live_cells, coords)),
            into: MapSet.new() do
          coords
        end

      %{matrix | live_cells: next_live_cells}
    end

    @spec to_rows(t()) :: list(list(0 | 1))
    def to_rows(%__MODULE__{width: width, height: height, live_cells: live_cells}) do
      for y <- 0..(height - 1)//1 do
        for x <- 0..(width - 1)//1 do
          cell_value(live_cells, {x, y})
        end
      end
    end

    @spec cell_value(MapSet.t(coords()), coords()) :: 0 | 1
    defp cell_value(live_cells, coords) do
      if MapSet.member?(live_cells, coords), do: 1, else: 0
    end

    @spec neighbours(t(), coords()) :: list(coords())
    def neighbours(%__MODULE__{width: width, height: height}, {x, y}) do
      for dy <- -1..1,
          dx <- -1..1,
          {dx, dy} != {0, 0},
          nx = x + dx,
          ny = y + dy,
          nx >= 0 and nx < width,
          ny >= 0 and ny < height do
        {nx, ny}
      end
    end

    @spec neighbours(t(), coords(), :live | :dead) :: list(coords())
    def neighbours(%__MODULE__{live_cells: live_cells} = matrix, coords, :live) do
      Enum.filter(neighbours(matrix, coords), &MapSet.member?(live_cells, &1))
    end

    def neighbours(%__MODULE__{live_cells: live_cells} = matrix, coords, :dead) do
      Enum.reject(neighbours(matrix, coords), &MapSet.member?(live_cells, &1))
    end
  end

  @doc """
  Apply the rules of Conway's Game of Life to a grid of cells
  """

  @spec tick(matrix :: list(list(0 | 1))) :: list(list(0 | 1))
  def tick(matrix) do
    matrix
    |> Matrix.new()
    |> Matrix.tick()
    |> Matrix.to_rows()
  end
end

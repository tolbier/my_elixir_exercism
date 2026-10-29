defmodule GameOfLifeTest do
  use ExUnit.Case

  test "Matrix.new stores dimensions and live cell coordinates" do
    matrix = GameOfLife.Matrix.new([[0, 1, 0], [1, 0, 1]])

    assert is_struct(matrix, GameOfLife.Matrix)
    assert matrix.width == 3
    assert matrix.height == 2
    assert matrix.live_cells == MapSet.new([{1, 0}, {0, 1}, {2, 1}])
  end

  test "Matrix.cells returns live coordinates in row order" do
    matrix = GameOfLife.Matrix.new([[0, 1, 0], [1, 0, 1]])

    assert GameOfLife.Matrix.cells(matrix, :live) == [{1, 0}, {0, 1}, {2, 1}]
  end

  test "Matrix.cells returns dead coordinates in row order" do
    matrix = GameOfLife.Matrix.new([[0, 1, 0], [1, 0, 1]])

    assert GameOfLife.Matrix.cells(matrix, :dead) == [{0, 0}, {2, 0}, {1, 1}]
  end

  test "Matrix.cells returns no coordinates for an empty matrix" do
    matrix = GameOfLife.Matrix.new([])

    assert GameOfLife.Matrix.cells(matrix, :live) == []
    assert GameOfLife.Matrix.cells(matrix, :dead) == []
  end

  test "Matrix.to_rows converts live cells to rows of zeros and ones" do
    matrix = GameOfLife.Matrix.new([[0, 1, 0], [1, 0, 1]])

    assert GameOfLife.Matrix.to_rows(matrix) == [[0, 1, 0], [1, 0, 1]]
  end

  test "Matrix.to_rows preserves dimensions when no cells are alive" do
    matrix = GameOfLife.Matrix.new([[0, 0, 0], [0, 0, 0]])

    assert GameOfLife.Matrix.to_rows(matrix) == [[0, 0, 0], [0, 0, 0]]
  end

  test "Matrix.to_rows returns an empty list for an empty matrix" do
    matrix = GameOfLife.Matrix.new([])

    assert GameOfLife.Matrix.to_rows(matrix) == []
  end

  test "Matrix.neighbours returns all neighbours around an interior cell" do
    matrix = GameOfLife.Matrix.new(List.duplicate([0, 0, 0], 3))

    assert GameOfLife.Matrix.neighbours(matrix, {1, 1}) == [
             {0, 0}, {1, 0}, {2, 0},
             {0, 1}, {2, 1},
             {0, 2}, {1, 2}, {2, 2}
           ]
  end

  test "Matrix.neighbours returns only in-bounds neighbours at a corner" do
    matrix = GameOfLife.Matrix.new(List.duplicate([0, 0, 0], 3))

    assert GameOfLife.Matrix.neighbours(matrix, {0, 0}) == [{1, 0}, {0, 1}, {1, 1}]
  end

  test "Matrix.neighbours returns live neighbours around an interior cell" do
    matrix = GameOfLife.Matrix.new([[1, 0, 1], [0, 0, 1], [1, 0, 0]])

    assert GameOfLife.Matrix.neighbours(matrix, {1, 1}, :live) == [
             {0, 0}, {2, 0}, {2, 1}, {0, 2}
           ]
  end

  test "Matrix.neighbours returns dead neighbours around an interior cell" do
    matrix = GameOfLife.Matrix.new([[1, 0, 1], [0, 0, 1], [1, 0, 0]])

    assert GameOfLife.Matrix.neighbours(matrix, {1, 1}, :dead) == [
             {1, 0}, {0, 1}, {1, 2}, {2, 2}
           ]
  end

  test "Matrix.neighbours excludes coordinates outside the matrix at a corner" do
    matrix = GameOfLife.Matrix.new([[1, 0, 0], [0, 1, 0], [0, 0, 0]])

    assert GameOfLife.Matrix.neighbours(matrix, {0, 0}, :live) == [{1, 1}]
    assert GameOfLife.Matrix.neighbours(matrix, {0, 0}, :dead) == [{1, 0}, {0, 1}]
  end

  test "Matrix.tick advances a blinker by one generation" do
    matrix = GameOfLife.Matrix.new([[0, 0, 0], [1, 1, 1], [0, 0, 0]])

    assert GameOfLife.Matrix.tick(matrix) ==
             GameOfLife.Matrix.new([[0, 1, 0], [0, 1, 0], [0, 1, 0]])
  end

  test "Matrix.tick removes cells with too many live neighbours" do
    matrix = GameOfLife.Matrix.new([[1, 1, 1], [1, 1, 1], [1, 1, 1]])

    assert GameOfLife.Matrix.tick(matrix) ==
             GameOfLife.Matrix.new([[1, 0, 1], [0, 0, 0], [1, 0, 1]])
  end

  test "Matrix.tick preserves dimensions when every cell dies" do
    matrix = GameOfLife.Matrix.new([[0, 0, 0], [0, 1, 0]])

    assert GameOfLife.Matrix.tick(matrix) == GameOfLife.Matrix.new([[0, 0, 0], [0, 0, 0]])
  end

  test "Matrix.tick returns an empty matrix for an empty matrix" do
    matrix = GameOfLife.Matrix.new([])

    assert GameOfLife.Matrix.tick(matrix) == matrix
  end

  test "Matrix.tick advances sparse live cells in a large matrix" do
    matrix =
      struct(GameOfLife.Matrix,
        width: 1_000_000,
        height: 1_000_000,
        live_cells: MapSet.new([{500_000, 500_000}, {500_001, 500_000}, {500_002, 500_000}])
      )

    next_matrix = GameOfLife.Matrix.tick(matrix)

    assert is_struct(next_matrix, GameOfLife.Matrix)
    assert next_matrix.width == 1_000_000
    assert next_matrix.height == 1_000_000

    assert next_matrix.live_cells ==
             MapSet.new([{500_001, 499_999}, {500_001, 500_000}, {500_001, 500_001}])
  end

  test "Matrix.tick handles one million positions with 50,000 live cells" do
    live_cells =
      for block_y <- 0..99,
          block_x <- 0..124,
          dy <- 0..1,
          dx <- 0..1,
          into: MapSet.new() do
        {block_x * 4 + dx, block_y * 4 + dy}
      end

    assert MapSet.size(live_cells) == 50_000

    matrix = struct(GameOfLife.Matrix, width: 1_000, height: 1_000, live_cells: live_cells)

    assert GameOfLife.Matrix.tick(matrix) == matrix
  end

  # @tag :pending
  test "empty matrix" do
    assert GameOfLife.tick([]) == []
  end

  @tag :pending
  test "live cells with zero live neighbors die" do
    matrix = [[0, 0, 0], [0, 1, 0], [0, 0, 0]]
    output = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "live cells with only one live neighbor die" do
    matrix = [[0, 0, 0], [0, 1, 0], [0, 1, 0]]
    output = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "live cells with two live neighbors stay alive" do
    matrix = [[1, 0, 1], [1, 0, 1], [1, 0, 1]]
    output = [[0, 0, 0], [1, 0, 1], [0, 0, 0]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "live cells with three live neighbors stay alive" do
    matrix = [[0, 1, 0], [1, 0, 0], [1, 1, 0]]
    output = [[0, 0, 0], [1, 0, 0], [1, 1, 0]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "dead cells with three live neighbors become alive" do
    matrix = [[1, 1, 0], [0, 0, 0], [1, 0, 0]]
    output = [[0, 0, 0], [1, 1, 0], [0, 0, 0]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "live cells with four or more neighbors die" do
    matrix = [[1, 1, 1], [1, 1, 1], [1, 1, 1]]
    output = [[1, 0, 1], [0, 0, 0], [1, 0, 1]]

    assert GameOfLife.tick(matrix) == output
  end

  @tag :pending
  test "bigger matrix" do
    matrix = [
      [1, 1, 0, 1, 1, 0, 0, 0],
      [1, 0, 1, 1, 0, 0, 0, 0],
      [1, 1, 1, 0, 0, 1, 1, 1],
      [0, 0, 0, 0, 0, 1, 1, 0],
      [1, 0, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 0, 0, 1, 1, 1],
      [0, 0, 1, 0, 1, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 1]
    ]

    output = [
      [1, 1, 0, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 0],
      [1, 0, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 0, 0, 1, 0, 0, 1],
      [1, 1, 0, 1, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 1]
    ]

    assert GameOfLife.tick(matrix) == output
  end
end

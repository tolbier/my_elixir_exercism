defmodule JigsawPuzzleBuildTest do
  use ExUnit.Case
  alias JigsawPuzzle, as: Puzzle

  test "completes a landscape puzzle" do
    assert Puzzle.build(pieces: 1000, aspect_ratio: 1.6) ==
             %Puzzle{
               pieces: 1000,
               rows: 25,
               columns: 40,
               aspect_ratio: 1.6,
               format: :landscape,
               border: 126,
               inside: 874
             }
  end

  test "completes a square puzzle" do
    assert Puzzle.build(pieces: 1024, aspect_ratio: 1.0) ==
             %Puzzle{
               pieces: 1024,
               rows: 32,
               columns: 32,
               aspect_ratio: 1.0,
               format: :square,
               border: 124,
               inside: 900
             }
  end

  test "completes a portrait puzzle" do
    assert Puzzle.build(pieces: 300, aspect_ratio: 0.48) ==
             %Puzzle{
               pieces: 300,
               rows: 25,
               columns: 12,
               aspect_ratio: 0.48,
               format: :portrait,
               border: 70,
               inside: 230
             }
  end

  test "handles a non-terminating aspect ratio" do
    assert Puzzle.build(pieces: 1500, aspect_ratio: 5 / 3) ==
             %Puzzle{
               pieces: 1500,
               rows: 30,
               columns: 50,
               aspect_ratio: 5 / 3,
               format: :landscape,
               border: 156,
               inside: 1344
             }
  end

  test "builds a complete puzzle from rows and columns" do
    assert Puzzle.build(%Puzzle{rows: 25, columns: 40}) ==
             %Puzzle{
               pieces: 1000,
               rows: 25,
               columns: 40,
               aspect_ratio: 1.6,
               format: :landscape,
               border: 126,
               inside: 874
             }
  end

  test "preserves an already completed puzzle" do
    puzzle = %Puzzle{
      pieces: 1000,
      rows: 25,
      columns: 40,
      aspect_ratio: 1.6,
      format: :landscape,
      border: 126,
      inside: 874
    }

    assert Puzzle.build(puzzle) == puzzle
  end

  test "recalculates pieces after truncating dimensions for later comparison" do
    assert Puzzle.build(pieces: 10, aspect_ratio: 1.0) ==
             %Puzzle{
               pieces: 9,
               rows: 3,
               columns: 3,
               aspect_ratio: 1.0,
               format: :square,
               border: 8,
               inside: 1
             }
  end
end

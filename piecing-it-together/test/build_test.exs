defmodule JigsawPuzzleCompletionTest do
  use ExUnit.Case
  alias JigsawPuzzle, as: Puzzle

  test "completes a landscape puzzle" do
    assert Puzzle.data(%Puzzle{pieces: 1000, aspect_ratio: 1.6}) ==
             {:ok,
              %Puzzle{
                pieces: 1000,
                rows: 25,
                columns: 40,
                aspect_ratio: 1.6,
                format: :landscape,
                border: 126,
                inside: 874
              }}
  end

  test "completes a square puzzle" do
    assert Puzzle.data(%Puzzle{pieces: 1024, aspect_ratio: 1.0}) ==
             {:ok,
              %Puzzle{
                pieces: 1024,
                rows: 32,
                columns: 32,
                aspect_ratio: 1.0,
                format: :square,
                border: 124,
                inside: 900
              }}
  end

  test "completes a portrait puzzle" do
    assert Puzzle.data(%Puzzle{pieces: 300, aspect_ratio: 0.48}) ==
             {:ok,
              %Puzzle{
                pieces: 300,
                rows: 25,
                columns: 12,
                aspect_ratio: 0.48,
                format: :portrait,
                border: 70,
                inside: 230
              }}
  end

  test "handles a non-terminating aspect ratio" do
    assert Puzzle.data(%Puzzle{pieces: 1500, aspect_ratio: 5 / 3}) ==
             {:ok,
              %Puzzle{
                pieces: 1500,
                rows: 30,
                columns: 50,
                aspect_ratio: 5 / 3,
                format: :landscape,
                border: 156,
                inside: 1344
              }}
  end

  test "builds a complete puzzle from rows and columns" do
    assert Puzzle.data(%Puzzle{rows: 25, columns: 40}) ==
             {:ok,
              %Puzzle{
                pieces: 1000,
                rows: 25,
                columns: 40,
                aspect_ratio: 1.6,
                format: :landscape,
                border: 126,
                inside: 874
              }}
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

    assert Puzzle.data(puzzle) == {:ok, puzzle}
  end

  test "rejects pieces inconsistent with the inferred dimensions" do
    assert Puzzle.data(%Puzzle{pieces: 10, aspect_ratio: 1.0}) ==
             {:error, "Contradictory data"}
  end
end

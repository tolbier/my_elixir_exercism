defmodule StateOfTicTacToe do
  @moduledoc "Determines the state of a tic-tac-toe game."

  @typep cell :: :x | :o | :empty
  @typep board :: [[cell()]]
  @typep pieces :: %{x: non_neg_integer(), o: non_neg_integer(), empty: non_neg_integer()}
  @typep state :: %{
           required(:board) => board(),
           optional(:pieces) => pieces(),
           optional(:x_winner) => boolean(),
           optional(:o_winner) => boolean()
         }

  @doc """
  Determine the state a game of tic-tac-toe where X starts.
  """
  @spec game_state(str :: String.t()) :: {:ok, :win | :ongoing | :draw} | {:error, String.t()}
  def game_state(str) do
    with state <- process_board(str),
         :ok <- validate(state) do
      do_game_state(state)
    end
  end

  @spec do_game_state(state()) :: {:ok, :win | :ongoing | :draw}
  defp do_game_state(%{x_winner: true}), do: {:ok, :win}
  defp do_game_state(%{o_winner: true}), do: {:ok, :win}
  defp do_game_state(%{pieces: %{empty: 0}}), do: {:ok, :draw}
  defp do_game_state(_), do: {:ok, :ongoing}

  @spec process_board(String.t()) :: state()
  defp process_board(str) do
    %{board: str_to_board(str)}
    |> add_piece_counts
    |> determine_winner
  end

  @spec validate(state()) :: :ok | {:error, String.t()}
  defp validate(%{pieces: %{o: o_pieces, x: x_pieces}}) when x_pieces > o_pieces + 1,
    do: {:error, "Wrong turn order: X went twice"}

  defp validate(%{pieces: %{o: o_pieces, x: x_pieces}}) when o_pieces > x_pieces,
    do: {:error, "Wrong turn order: O started"}

  defp validate(%{x_winner: true, pieces: %{o: o_pieces, x: x_pieces}})
       when o_pieces == x_pieces,
       do: {:error, "Impossible board: game should have ended after the game was won"}

  defp validate(%{o_winner: true, pieces: %{o: o_pieces, x: x_pieces}})
       when x_pieces > o_pieces,
       do: {:error, "Impossible board: game should have ended after the game was won"}

  defp validate(_), do: :ok

  @spec add_piece_counts(state()) :: state()
  defp add_piece_counts(state = %{board: board}) do
    Map.put(state, :pieces, count_pieces(board))
  end

  @spec count_pieces(board()) :: pieces()
  defp count_pieces(board) do
    counts = board |> List.flatten() |> Enum.frequencies()
    Map.merge(%{x: 0, o: 0, empty: 0}, counts)
  end

  @spec determine_winner(state()) :: state()
  defp determine_winner(state = %{board: board}) do
    Map.merge(state, %{x_winner: win?(:x, board), o_winner: win?(:o, board)})
  end

  @spec str_to_board(String.t()) :: board()
  defp str_to_board(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.graphemes()
      |> Enum.map(&cell_to_atom/1)
    end)
  end

  @spec cell_to_atom(String.t()) :: :x | :o | :empty
  defp cell_to_atom("X"), do: :x
  defp cell_to_atom("O"), do: :o
  defp cell_to_atom("."), do: :empty

  @spec win?(:x | :o, board()) :: boolean()
  defp win?(c, [[c, c, c], _, _]), do: true
  defp win?(c, [_, [c, c, c], _]), do: true
  defp win?(c, [_, _, [c, c, c]]), do: true
  defp win?(c, [[c, _, _], [c, _, _], [c, _, _]]), do: true
  defp win?(c, [[_, c, _], [_, c, _], [_, c, _]]), do: true
  defp win?(c, [[_, _, c], [_, _, c], [_, _, c]]), do: true
  defp win?(c, [[c, _, _], [_, c, _], [_, _, c]]), do: true
  defp win?(c, [[_, _, c], [_, c, _], [c, _, _]]), do: true
  defp win?(_c, _board), do: false
end

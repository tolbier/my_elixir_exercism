defmodule Bowling do
  @moduledoc """
  Records the rolls of a bowling game and calculates its score.
  """

  defstruct rolls: [], current_frame: []

  @typedoc "Pins knocked down in a single valid roll"
  @type pins :: 0..10

  @typedoc """
  A game in progress. `rolls` holds every roll, most recent first;
  `current_frame` holds the first roll of an unfinished frame, needed to
  validate the second one.
  """
  @type t :: %__MODULE__{rolls: [pins()], current_frame: [pins()]}

  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """
  @spec start() :: t()
  def start, do: %__MODULE__{}

  @doc """
    Records the number of pins knocked down on a single roll. Returns
    `{:ok, game}` with the roll added, or a helpful error tuple if the number
    of pins is invalid or the game is already over.
  """
  @spec roll(t(), integer) :: {:ok, t()} | {:error, String.t()}
  def roll(game, pins) do
    if game_over?(game),
      do: {:error, "Cannot roll after game is over"},
      else: record_roll(game, pins)
  end

  # The game is over once every frame, fill balls included, can be scored.
  @spec game_over?(t()) :: boolean
  defp game_over?(game), do: match?({:ok, _total}, score(game))

  @spec record_roll(t(), integer) :: {:ok, t()} | {:error, String.t()}
  defp record_roll(_game, pins) when pins < 0, do: {:error, "Negative roll is invalid"}

  defp record_roll(%__MODULE__{current_frame: []}, pins) when pins > 10,
    do: {:error, "Pin count exceeds pins on the lane"}

  defp record_roll(%__MODULE__{current_frame: [first_roll]}, pins) when first_roll + pins > 10,
    do: {:error, "Pin count exceeds pins on the lane"}

  defp record_roll(game = %__MODULE__{current_frame: []}, 10),
    do: {:ok, %{game | rolls: [10 | game.rolls]}}

  defp record_roll(game = %__MODULE__{current_frame: []}, pins),
    do: {:ok, %{game | rolls: [pins | game.rolls], current_frame: [pins]}}

  defp record_roll(game = %__MODULE__{current_frame: [_first_roll]}, pins),
    do: {:ok, %{game | rolls: [pins | game.rolls], current_frame: []}}

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful error tuple.
  """
  @spec score(t()) :: {:ok, non_neg_integer} | {:error, String.t()}
  def score(%__MODULE__{rolls: rolls}), do: rolls |> Enum.reverse() |> score_frames(1, 0)

  # Walks the rolls in order, one frame at a time. Bonus rolls are only read,
  # not consumed, so they are also counted in their own frame. After frame 10
  # any remaining rolls are fill balls already counted as bonus.
  @spec score_frames([pins()], pos_integer, non_neg_integer) ::
          {:ok, non_neg_integer} | {:error, String.t()}
  defp score_frames(_rolls, 11, total), do: {:ok, total}

  defp score_frames([10 | rest = [bonus_1, bonus_2 | _]], frame, total),
    do: score_frames(rest, frame + 1, total + 10 + bonus_1 + bonus_2)

  defp score_frames([first, second | rest = [bonus | _]], frame, total) when first + second == 10,
    do: score_frames(rest, frame + 1, total + 10 + bonus)

  defp score_frames([first, second | rest], frame, total) when first + second < 10,
    do: score_frames(rest, frame + 1, total + first + second)

  # Not enough rolls to finish the frame or to know its bonus.
  defp score_frames(_rolls, _frame, _total),
    do: {:error, "Score cannot be taken until the end of the game"}
end

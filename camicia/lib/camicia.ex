defmodule Camicia do
  @moduledoc "Simulates a two-player game of Camicia."

  @doc """
    Simulate a card game between two players.
    Each player has a deck of cards represented as a list of strings.
    Returns a tuple with the result of the game:
    - `{:finished, cards, tricks}` if the game finishes with a winner
    - `{:loop, cards, tricks}` if the game enters a loop
    `cards` is the number of cards played.
    `tricks` is the number of central piles collected.

    ## Examples

      iex> Camicia.simulate(["2"], ["3"])
      {:finished, 2, 1}

      iex> Camicia.simulate(["J", "2", "3"], ["4", "J", "5"])
      {:loop, 8, 3}
  """
  @penalties %{
    "J" => 1,
    "Q" => 2,
    "K" => 3,
    "A" => 4
  }

  @payment_cards Map.keys(@penalties)

  @typep deck :: [String.t()]
  @typep player :: {:a | :b, deck()}
  @typep result :: {:finished | :loop, non_neg_integer(), non_neg_integer()}
  @typep state :: %{
           pile: deck(),
           penalty: nil | non_neg_integer(),
           cards: non_neg_integer(),
           tricks: non_neg_integer(),
           snapshots: %{optional(String.t()) => true},
           check_loop: boolean()
         }

  @spec simulate(deck(), deck()) :: result()
  def simulate(deck_a, deck_b) do
    do_simulate({:a, deck_a}, {:b, deck_b}, %{
      pile: [],
      penalty: nil,
      cards: 0,
      tricks: 0,
      snapshots: %{},
      check_loop: true
    })
  end

  @spec do_simulate(player(), player(), state()) :: result()
  # Check the starting decks of a round for a repeated game state.
  defp do_simulate(
         player1,
         player2,
         state = %{
           cards: cards,
           tricks: tricks,
           check_loop: true
         }
       ) do
    snapshot = snapshot(player1, player2)

    if Map.has_key?(state.snapshots, snapshot) do
      {:loop, cards, tricks}
    else
      do_simulate(player1, player2, %{
        state
        | snapshots: Map.put(state.snapshots, snapshot, true),
          check_loop: false
      })
    end
  end

  # A player owns every card after a trick.
  defp do_simulate(_player1, _player2 = {_, []}, %{
         pile: [],
         cards: cards,
         tricks: tricks
       }),
       do: {:finished, cards, tricks}

  # The player who placed the last payment card collects the paid penalty.
  defp do_simulate(
         player1,
         player2,
         state = %{
           penalty: 0
         }
       ),
       do: trick(player1, player2, state)

  # A payment card gives the other player a new penalty.
  defp do_simulate(
         {id1, [card1 | rest1]},
         player2,
         state = %{
           pile: pile,
           cards: cards
         }
       )
       when card1 in @payment_cards,
       do:
         do_simulate(player2, {id1, rest1}, %{
           state
           | pile: [card1 | pile],
             penalty: @penalties[card1],
             cards: cards + 1
         })

  # Continue paying a penalty when the next card is a number card.
  defp do_simulate(
         {id1, [card1 | rest1]},
         player2,
         state = %{
           pile: pile,
           penalty: penalty,
           cards: cards
         }
       )
       when is_number(penalty),
       do:
         do_simulate({id1, rest1}, player2, %{
           state
           | pile: [card1 | pile],
             penalty: penalty - 1,
             cards: cards + 1
         })

  # A number card passes the turn to the other player.
  defp do_simulate(
         {id1, [card1 | rest1]},
         player2,
         state = %{
           pile: pile,
           cards: cards
         }
       ),
       do: do_simulate(player2, {id1, rest1}, %{state | pile: [card1 | pile], cards: cards + 1})

  # If the current player cannot play, the other player collects the pile.
  defp do_simulate(player1 = {_, []}, player2, state),
    do: trick(player1, player2, state)

  @spec trick(player(), player(), state()) :: result()
  # Give the pile to the winner and start the next round.
  defp trick(
         player1,
         {id2, deck2},
         state = %{
           pile: pile,
           tricks: tricks
         }
       ) do
    do_simulate({id2, deck2 ++ Enum.reverse(pile)}, player1, %{
      state
      | pile: [],
        penalty: nil,
        tricks: tricks + 1,
        check_loop: true
    })
  end

  @spec snapshot(player(), player()) :: String.t()
  # Put player A first so swapped turn arguments have the same key.
  defp snapshot(player1 = {:b, _}, player2 = {:a, _}), do: snapshot(player2, player1)

  # Combine both players' normalized decks into one snapshot.
  defp snapshot({:a, deck_a}, {:b, deck_b}) do
    "A:#{deck_snapshot(deck_a)}-B:#{deck_snapshot(deck_b)}"
  end

  @spec deck_snapshot(deck()) :: String.t()
  # Preserve payment cards and replace each number card with N.
  defp deck_snapshot(deck) do
    Enum.map(deck, fn card ->
      if card in @payment_cards, do: card, else: "N"
    end)
    |> List.to_string()
  end
end

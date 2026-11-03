defmodule Alphametics do
  @moduledoc """
  Solves alphametics as a weighted sum of digits equal to zero.

  For example, `AB + C == BA` becomes `9*A - 9*B + C == 0`. Letters with
  larger absolute weights are assigned first. A branch stops as soon as the
  remaining digits cannot bring the sum back to zero.
  """

  @type letter :: ?A..?Z
  @type digit :: 0..9
  @type solution :: %{optional(letter()) => digit()}
  @typep weighted_letter :: {letter(), integer()}

  @doc """
  Returns the first valid assignment, or `nil` when no solution exists.
  Digits must be distinct, and multi-letter words cannot start with zero.

  ## Examples

      iex> Alphametics.solve("I + BB == ILL")
      %{?I => 1, ?B => 9, ?L => 0}

      iex> Alphametics.solve("A == B")
      nil
  """
  @spec solve(String.t()) :: solution() | nil
  def solve(puzzle) do
    words = parse_words(puzzle)
    {addends, [result]} = Enum.split(words, -1)
    weights = letter_weights(addends, result)

    if map_size(weights) <= 10 do
      weighted_letters = Enum.sort_by(weights, fn {letter, weight} -> {-abs(weight), letter} end)
      search(weighted_letters, 0, Enum.to_list(0..9), nonzero_letters(words))
    end
  end

  @spec parse_words(String.t()) :: [charlist()]
  defp parse_words(puzzle) do
    ~r/[A-Z]+/
    |> Regex.scan(puzzle)
    |> Enum.map(fn [word] -> String.to_charlist(word) end)
  end

  @spec nonzero_letters([charlist()]) :: MapSet.t(letter())
  defp nonzero_letters(words) do
    words
    |> Enum.filter(&(length(&1) > 1))
    |> Enum.map(&hd/1)
    |> MapSet.new()
  end

  @spec letter_weights([charlist()], charlist()) :: %{letter() => integer()}
  defp letter_weights(addends, result) do
    contributions =
      Enum.flat_map(addends, &word_contributions(&1, 1)) ++ word_contributions(result, -1)

    Enum.reduce(contributions, %{}, fn {letter, weight}, weights ->
      Map.update(weights, letter, weight, &(&1 + weight))
    end)
  end

  @spec word_contributions(charlist(), -1 | 1) :: [weighted_letter()]
  defp word_contributions(word, sign) do
    word
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {letter, position} -> {letter, sign * Integer.pow(10, position)} end)
  end

  @spec search([weighted_letter()], integer(), [digit()], MapSet.t(letter())) :: solution() | nil
  defp search([], 0, _available_digits, _nonzero_letters), do: %{}
  defp search([], _partial_sum, _available_digits, _nonzero_letters), do: nil

  defp search(
         [{letter, _weight} | _remaining_letters] = weighted_letters,
         partial_sum,
         available_digits,
         nonzero_letters
       ) do
    if can_reach_zero?(weighted_letters, partial_sum, available_digits) do
      letter
      |> candidate_digits(available_digits, nonzero_letters)
      |> Enum.find_value(fn digit ->
        try_digit(digit, weighted_letters, partial_sum, available_digits, nonzero_letters)
      end)
    end
  end

  @spec candidate_digits(letter(), [digit()], MapSet.t(letter())) :: [digit()]
  defp candidate_digits(letter, available_digits, nonzero_letters) do
    if MapSet.member?(nonzero_letters, letter),
      do: List.delete(available_digits, 0),
      else: available_digits
  end

  @spec try_digit(digit(), [weighted_letter()], integer(), [digit()], MapSet.t(letter())) ::
          solution() | nil
  defp try_digit(
         digit,
         [{letter, weight} | remaining_letters],
         partial_sum,
         available_digits,
         nonzero_letters
       ) do
    remaining_digits = List.delete(available_digits, digit)
    next_sum = partial_sum + weight * digit
    solution = search(remaining_letters, next_sum, remaining_digits, nonzero_letters)

    add_assignment(solution, letter, digit)
  end

  @spec add_assignment(solution() | nil, letter(), digit()) :: solution() | nil
  defp add_assignment(nil, _letter, _digit), do: nil
  defp add_assignment(solution, letter, digit), do: Map.put(solution, letter, digit)

  @spec can_reach_zero?([weighted_letter()], integer(), [digit()]) :: boolean()
  defp can_reach_zero?(remaining_letters, partial_sum, available_digits) do
    {minimum, maximum} = remaining_sum_bounds(remaining_letters, available_digits)
    partial_sum + minimum <= 0 and partial_sum + maximum >= 0
  end

  @spec remaining_sum_bounds([weighted_letter()], [digit()]) :: {integer(), integer()}
  defp remaining_sum_bounds(weighted_letters, available_digits) do
    digit_bounds = Enum.min_max(available_digits)

    # Ignore digit uniqueness only for this estimate: the wider interval can
    # keep extra branches, but never discards a valid solution.
    Enum.reduce(weighted_letters, {0, 0}, fn {_letter, weight}, {minimum, maximum} ->
      {least, most} = contribution_bounds(weight, digit_bounds)
      {minimum + least, maximum + most}
    end)
  end

  @spec contribution_bounds(integer(), {digit(), digit()}) :: {integer(), integer()}
  defp contribution_bounds(weight, {lowest_digit, highest_digit}) do
    Enum.min_max([weight * lowest_digit, weight * highest_digit])
  end
end

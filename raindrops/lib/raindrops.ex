defmodule Raindrops do
  @moduledoc """
  Converts a number into its raindrop sound representation.
  """

  @doc """
  Returns a string based on raindrop factors.

  - If the number contains 3 as a prime factor, output 'Pling'.
  - If the number contains 5 as a prime factor, output 'Plang'.
  - If the number contains 7 as a prime factor, output 'Plong'.
  - If the number does not contain 3, 5, or 7 as a prime factor,
    just pass the number's digits straight through.
  """
  @spec convert(pos_integer) :: String.t()
  def convert(number) do
    {number, ""}
    |> raindrop(3, "Pling")
    |> raindrop(5, "Plang")
    |> raindrop(7, "Plong")
    |> output
  end

  @spec output({pos_integer, String.t()}) :: String.t()
  defp output({number, ""}), do: to_string(number)
  defp output({_, text}), do: text

  @spec raindrop({pos_integer, String.t()}, pos_integer, String.t()) ::
          {pos_integer, String.t()}
  defp raindrop({number, acc}, divisor, text) when rem(number, divisor) == 0,
    do: {number, acc <> text}

  defp raindrop({number, acc}, _divisor, _text),
    do: {number, acc}
end

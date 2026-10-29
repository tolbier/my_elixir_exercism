defmodule LineUp do
  @moduledoc """
  Formats the ticket message announced to each customer in a queue.
  """

  @doc """
  Formats a full ticket sentence for the given name and number, including
  the person's name, the ordinal form of the number, and fixed descriptive text.
  """
  @spec format(name :: String.t(), number :: pos_integer()) :: String.t()
  def format(name, number) do
    "#{name}, you are the #{number}#{number |> number_suffix} customer we serve today. Thank you!"
  end

  @spec number_suffix(pos_integer()) :: String.t()
  defp number_suffix(number) do
    tens = tens(number)
    units = units(number)

    case tens do
      1 ->
        "th"

      _ ->
        case units do
          1 -> "st"
          2 -> "nd"
          3 -> "rd"
          _ -> "th"
        end
    end
  end

  @spec tens(integer()) :: 0..9
  def tens(n) do
    n
    |> abs()
    |> div(10)
    |> rem(10)
  end

  @spec units(integer()) :: 0..9
  def units(n) do
    n
    |> abs()
    |> rem(10)
  end
end

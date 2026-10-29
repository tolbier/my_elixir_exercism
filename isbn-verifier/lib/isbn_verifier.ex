defmodule IsbnVerifier do
  @moduledoc """
  Verifies whether a string is a valid ISBN-10 identifier.
  """

  @doc """
    Checks if a string is a valid ISBN-10 identifier

    ## Examples

      iex> IsbnVerifier.isbn?("3-598-21507-X")
      true

      iex> IsbnVerifier.isbn?("3-598-2K507-0")
      false

  """
  @spec isbn?(String.t()) :: boolean
  def isbn?(isbn) do
    charlist = isbn |> String.to_charlist() |> Enum.reject(&(&1 == ?-))

    with {digits, [check_digit]} <- Enum.split(charlist, 9),
         true <- Enum.all?(digits, fn c -> c in ?0..?9 end),
         true <- check_digit == ?X or check_digit in ?0..?9,
         :ok <- checksum(digits, check_digit) do
      true
    else
      _ -> false
    end
  end

  @spec checksum([char], char) :: :ok | :error
  defp checksum(digits, check_digit) do
    case (digits ++
            [
              case check_digit do
                ?X -> ?0 + 10
                c -> c
              end
            ])
         |> Enum.with_index()
         |> Enum.map(fn {it, idx} -> (10 - idx) * (it - ?0) end)
         |> Enum.sum()
         |> rem(11) do
      0 -> :ok
      _ -> :error
    end
  end
end

defmodule Transpose do
  @doc """
  Given an input text, output it transposed.

  Rows become columns and columns become rows. See https://en.wikipedia.org/wiki/Transpose.

  If the input has rows of different lengths, this is to be solved as follows:
    * Pad to the left with spaces.
    * Don't pad to the right.

  ## Examples

    iex> Transpose.transpose("ABC\\nDE")
    "AD\\nBE\\nC"

    iex> Transpose.transpose("AB\\nDEF")
    "AD\\nBE\\n F"
  """
  @spec transpose(String.t()) :: String.t()
  def transpose(input) do
    input
    |> lines()
    |> pad_lines_to_max_length()
    |> graphemes_list()
    |> transpose_list()
    |> rows_to_string()
  end

  defp lines(str) do
    str
    |> String.split("\n")
  end

  defp graphemes_list(lines) do
    lines
    |> Enum.map(&String.graphemes/1)
  end

  defp transpose_list(rows), do: do_transpose(rows, [])

  defp do_transpose(rows, acc) do
    if Enum.all?(rows, &(&1 == [])) do
      Enum.reverse(acc)
    else
      heads = rows |> Enum.map(&List.first/1) |> Enum.reject(&is_nil/1)

      tails =
        Enum.map(rows, fn
          [] -> []
          [_ | rest] -> rest
        end)

      do_transpose(tails, [heads | acc])
    end
  end

  defp rows_to_string(lists) do
    lists
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  defp pad_lines_to_max_length(lines) do
    {padded, _running_max} =
      lines
      |> Enum.reverse()
      |> Enum.map_reduce(0, fn line, running_max ->
        target = max(String.length(line), running_max)
        {String.pad_trailing(line, target), target}
      end)

    Enum.reverse(padded)
  end
end

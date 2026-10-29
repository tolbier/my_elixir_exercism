defmodule AllYourBase do
  @doc """
  Given a number in input base, represented as a sequence of digits, converts it to output base,
  or returns an error tuple if either of the bases are less than 2
  """

  @spec convert(list, integer, integer) :: {:ok, list} | {:error, String.t()}
  def convert(digits, input_base, output_base) do
    cond do
      input_base < 2 ->
        {:error, "input base must be >= 2"}

      output_base < 2 ->
        {:error, "output base must be >= 2"}

      Enum.any?(digits, &(&1 < 0 or &1 >= input_base)) ->
        {:error, "all digits must be >= 0 and < input base"}

      true ->
        digits
        |> input_to_decimal(input_base)
        |> decimal_to_base(output_base)
        |> then(&{:ok, &1})
    end
  end

  defp input_to_decimal(digits, input_base) do
    digits
    |> Enum.reduce(0, fn digit, acc ->
      acc * input_base + digit
    end)
  end

  defp decimal_to_base(0, _base), do: [0]
  defp decimal_to_base(number, base), do: do_base_div(number, base, [])

  defp do_base_div(0, _base, acc), do: acc

  defp do_base_div(number, base, acc) do
    do_base_div(div(number, base), base, [rem(number, base) | acc])
  end
end

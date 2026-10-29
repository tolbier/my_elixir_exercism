defmodule Series do
  @moduledoc """
  Finds the largest product of a series of consecutive digits within a string of digits.
  """

  @doc """
  Finds the largest product of a given number of consecutive numbers in a given string of numbers.
  """

  @spec largest_product(String.t(), non_neg_integer) :: non_neg_integer
  def largest_product(_number_string, 0), do: 1

  def largest_product(number_string, size)
      when byte_size(number_string) >= size and size > 0 do
    number_string
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(size, 1, :discard)
    |> Enum.map(&Enum.product/1)
    |> Enum.max()
  end

  def largest_product(_number_string, _size), do: raise(ArgumentError)
end

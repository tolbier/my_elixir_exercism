defmodule Triangle do
  @moduledoc """
  Determines the kind of a triangle from its side lengths.
  """

  @type kind :: :equilateral | :isosceles | :scalene

  @doc """
  Return the kind of triangle of a triangle with 'a', 'b' and 'c' as lengths.
  """
  @spec kind(number, number, number) :: {:ok, kind} | {:error, String.t()}
  def kind(a, b, c) when a <= 0 or b <= 0 or c <= 0,
    do: {:error, "all side lengths must be positive"}

  def kind(a, b, c)
      when a + b < c or b + c < a or a + c < b,
      do: {:error, "side lengths violate triangle inequality"}

  def kind(a, b, c) do
    {:ok,
     case {a, b, c} do
       {a, a, a} -> :equilateral
       {a, a, _} -> :isosceles
       {a, _, a} -> :isosceles
       {_, a, a} -> :isosceles
       _ -> :scalene
     end}
  end
end

defmodule LucasNumbers do
  @moduledoc """
  Lucas numbers are an infinite sequence of numbers which build progressively
  which hold a strong correlation to the golden ratio (φ or ϕ)

  E.g.: 2, 1, 3, 4, 7, 11, 18, 29, ...
  """
  def generate(1), do: [2]
  def generate(2), do: [2, 1]

  def generate(n) when is_integer(n) and n > 2 do
    Stream.iterate({2, 1}, fn {a, b} -> {b, a + b} end)
    |> Stream.map(fn {a, _b} -> a end)
    |> Enum.take(n)
  end

  def generate(_), do: raise(ArgumentError, "count must be specified as an integer >= 1")
end

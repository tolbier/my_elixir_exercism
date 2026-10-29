defmodule Strain do
  @moduledoc """
  Filters lists without using `Enum.filter/2` or `Enum.reject/2`.
  """

  @doc """
  Given a `list` of items and a function `fun`, return the list of items where
  `fun` returns true.

  Do not use `Enum.filter`.
  """
  @spec keep(list :: list(any), fun :: (any -> boolean)) :: list(any)
  def keep([item | rest], fun) do
    rest_kept = keep(rest, fun)

    if fun.(item) do
      [item | rest_kept]
    else
      rest_kept
    end
  end

  def keep([], _), do: []

  @doc """
  Given a `list` of items and a function `fun`, return the list of items where
  `fun` returns false.

  Do not use `Enum.reject`.
  """
  @spec discard(list :: list(any), fun :: (any -> boolean)) :: list(any)
  def discard(list, fun), do: keep(list, &(!fun.(&1)))
end

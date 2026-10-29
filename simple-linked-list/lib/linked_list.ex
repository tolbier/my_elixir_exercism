defmodule LinkedList do
  @moduledoc """
  A singly linked list backed by nested tuples.
  """

  @opaque t :: {} | {any(), t}

  @empty_list {}
  @error_empty_list {:error, :empty_list}

  @type empty_list_error :: {:error, :empty_list}

  @doc """
  Construct a new LinkedList
  """
  @spec new() :: t
  def new, do: @empty_list

  @doc """
  Push an item onto a LinkedList
  """
  @spec push(t, any()) :: t
  def push(list, elem), do: {elem, list}

  @doc """
  Counts the number of elements in a LinkedList
  """
  @spec count(t) :: non_neg_integer()
  def count(list), do: do_count(list, 0)

  @spec do_count(t, non_neg_integer()) :: non_neg_integer()
  defp do_count(@empty_list, acc), do: acc
  defp do_count({_, tail}, acc), do: do_count(tail, acc + 1)

  @doc """
  Determine if a LinkedList is empty
  """
  @spec empty?(t) :: boolean()
  def empty?(@empty_list), do: true
  def empty?(_), do: false

  @doc """
  Get the value of a head of the LinkedList
  """
  @spec peek(t) :: {:ok, any()} | empty_list_error
  def peek(@empty_list), do: @error_empty_list
  def peek({elem, _}), do: {:ok, elem}

  @doc """
  Get tail of a LinkedList
  """
  @spec tail(t) :: {:ok, t} | empty_list_error
  def tail(@empty_list), do: @error_empty_list
  def tail({_, tail}), do: {:ok, tail}

  @doc """
  Remove the head from a LinkedList
  """
  @spec pop(t) :: {:ok, any(), t} | empty_list_error
  def pop(@empty_list), do: @error_empty_list
  def pop({elem, tail}), do: {:ok, elem, tail}

  @doc """
  Construct a LinkedList from a stdlib List
  """
  @spec from_list(list()) :: t
  def from_list(list), do: do_from_list(list, @empty_list)
  @spec do_from_list(list(), t) :: t
  defp do_from_list([], acc), do: reverse(acc)
  defp do_from_list([h | t], acc), do: do_from_list(t, push(acc, h))

  @doc """
  Construct a stdlib List LinkedList from a LinkedList
  """
  @spec to_list(t) :: list()
  def to_list(list), do: do_to_list(list, [])

  @spec do_to_list(t, list()) :: list()
  defp do_to_list(@empty_list, acc), do: Enum.reverse(acc)
  defp do_to_list({elem, tail}, acc), do: do_to_list(tail, [elem | acc])

  @doc """
  Reverse a LinkedList
  """
  @spec reverse(t) :: t
  def reverse(list), do: do_reverse(list, @empty_list)
  @spec do_reverse(t, t) :: t
  defp do_reverse(@empty_list, acc), do: acc
  defp do_reverse({elem, tail}, acc), do: do_reverse(tail, push(acc, elem))
end

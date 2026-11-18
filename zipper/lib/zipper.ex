defmodule Zipper do
  @moduledoc """
  A zipper over a binary tree: a focus node plus the path back to the root.
  """

  alias BinTree, as: BT

  defstruct [:focus, trail: []]

  # One step down from a parent: the direction taken, the parent's value and
  # the subtree left behind on the other side, enough to rebuild the parent.
  @typep crumb :: {:left | :right, parent_value :: any, sibling :: BT.t() | nil}

  # The trail holds the most recent step first
  @type t :: %Zipper{focus: BT.t(), trail: [crumb()]}

  @doc """
  Get a zipper focused on the root node.
  """
  @spec from_tree(BT.t()) :: t()
  def from_tree(tree), do: %Zipper{focus: tree}

  @doc """
  Get the complete tree from a zipper.
  """
  @spec to_tree(t()) :: BT.t()
  def to_tree(%Zipper{focus: tree, trail: []}), do: tree
  def to_tree(zipper), do: zipper |> up() |> to_tree()

  @doc """
  Get the value of the focus node.
  """
  @spec value(t()) :: any
  def value(%Zipper{focus: %BT{value: value}}), do: value

  @doc """
  Get the left child of the focus node, if any.
  """
  @spec left(t()) :: t() | nil
  def left(%Zipper{focus: %BT{left: nil}}), do: nil

  def left(%Zipper{focus: %BT{value: value, left: left, right: right}, trail: trail}),
    do: %Zipper{focus: left, trail: [{:left, value, right} | trail]}

  @doc """
  Get the right child of the focus node, if any.
  """
  @spec right(t()) :: t() | nil
  def right(%Zipper{focus: %BT{right: nil}}), do: nil

  def right(%Zipper{focus: %BT{value: value, left: left, right: right}, trail: trail}),
    do: %Zipper{focus: right, trail: [{:right, value, left} | trail]}

  @doc """
  Get the parent of the focus node, if any.
  """
  @spec up(t()) :: t() | nil
  def up(%Zipper{trail: []}), do: nil

  def up(%Zipper{focus: tree, trail: [crumb | rest_crumbs]}),
    do: %Zipper{focus: rebuild_parent(crumb, tree), trail: rest_crumbs}

  # Puts the child back on the side it came from, next to the sibling left behind
  @spec rebuild_parent(crumb(), BT.t()) :: BT.t()
  defp rebuild_parent({:left, value, sibling}, child),
    do: %BT{value: value, left: child, right: sibling}

  defp rebuild_parent({:right, value, sibling}, child),
    do: %BT{value: value, left: sibling, right: child}

  @doc """
  Set the value of the focus node.
  """
  @spec set_value(t(), any) :: t()
  def set_value(zipper, value), do: put_in(zipper.focus.value, value)

  @doc """
  Replace the left child tree of the focus node.
  """
  @spec set_left(t(), BT.t() | nil) :: t()
  def set_left(zipper, left), do: put_in(zipper.focus.left, left)

  @doc """
  Replace the right child tree of the focus node.
  """
  @spec set_right(t(), BT.t() | nil) :: t()
  def set_right(zipper, right), do: put_in(zipper.focus.right, right)
end

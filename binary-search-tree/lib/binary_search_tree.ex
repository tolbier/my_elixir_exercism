defmodule BinarySearchTree do
  @moduledoc """
  A Binary Search Tree that stores values and traverses them in order.
  """

  defmodule Node do
    @moduledoc """
    A node of a Binary Search Tree.
    """

    defstruct data: nil, left: nil, right: nil

    @type t :: %__MODULE__{data: any, left: t | nil, right: t | nil}
  end

  @type bst_node :: Node.t()

  @doc """
  Create a new Binary Search Tree with root's value as the given 'data'
  """
  @spec new(any) :: bst_node
  def new(data) do
    %Node{data: data}
  end

  @doc """
  Creates and inserts a node with its value as 'data' into the tree.
  """
  @spec insert(bst_node, any) :: bst_node
  def insert(nil, data), do: new(data)

  def insert(tree = %{data: tdata, left: left}, data) when data <= tdata,
    do: %{tree | left: left |> insert(data)}

  def insert(tree = %{right: right}, data),
    do: %{tree | right: right |> insert(data)}

  @doc """
  Traverses the Binary Search Tree in order and returns a list of each node's data.
  """
  @spec in_order(bst_node) :: [any]
  def in_order(nil), do: []

  def in_order(tree) do
    in_order(tree.left) ++ [tree.data] ++ in_order(tree.right)
  end
end

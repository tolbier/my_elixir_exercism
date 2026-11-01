defmodule Satellite do
  @moduledoc "Reconstructs binary trees from preorder and inorder traversals."

  @typedoc """
  A tree, which can be empty, or made from a left branch, a node and a right branch
  """
  @type tree :: {} | {tree, any, tree}

  @doc """
  Build a tree from the elements given in a pre-order and in-order style
  """
  @spec build_tree(preorder :: [any], inorder :: [any]) :: {:ok, tree} | {:error, String.t()}

  def build_tree(preorder, inorder) do
    with :ok <- validate(preorder, inorder) do
      do_build_tree(preorder, inorder)
    end
  end

  @spec do_build_tree([any()], [any()]) :: {:ok, tree()} | {:error, String.t()}
  defp do_build_tree([], []), do: {:ok, {}}

  defp do_build_tree([root | rest_preorder], inorder) do
    with {:ok, {left_inorder, right_inorder}} <- split_inorder(root, inorder),
         {left_preorder, right_preorder} <- Enum.split(rest_preorder, length(left_inorder)),
         {:ok, left_tree} <- do_build_tree(left_preorder, left_inorder),
         {:ok, right_tree} <- do_build_tree(right_preorder, right_inorder) do
      {:ok, {left_tree, root, right_tree}}
    end
  end

  @spec validate([any()], [any()]) :: :ok | {:error, String.t()}
  defp validate(preorder, inorder) do
    with :ok <- validate_same_length(preorder, inorder),
         :ok <- validate_unique_elements(preorder, inorder) do
      validate_same_elements(preorder, inorder)
    end
  end

  @spec validate_same_length([any()], [any()]) :: :ok | {:error, String.t()}
  defp validate_same_length(preorder, inorder) when length(preorder) != length(inorder),
    do: {:error, "traversals must have the same length"}

  defp validate_same_length(_, _), do: :ok

  @spec validate_unique_elements([any()], [any()]) :: :ok | {:error, String.t()}
  defp validate_unique_elements(preorder, inorder) do
    with :ok <- validate_unique_elements(preorder) do
      validate_unique_elements(inorder)
    end
  end

  @spec validate_unique_elements([any()]) :: :ok | {:error, String.t()}
  defp validate_unique_elements(list) do
    if length(list) == length(Enum.uniq(list)) do
      :ok
    else
      {:error, "traversals must contain unique items"}
    end
  end

  @spec validate_same_elements([any()], [any()]) :: :ok | {:error, String.t()}
  defp validate_same_elements(preorder, inorder) do
    if Enum.sort(preorder) == Enum.sort(inorder) do
      :ok
    else
      {:error, "traversals must have the same elements"}
    end
  end

  @spec split_inorder(any(), [any()]) :: {:ok, {[any()], [any()]}} | {:error, String.t()}
  defp split_inorder(root, inorder) do
    case Enum.split_while(inorder, &(&1 != root)) do
      {left, [^root | right]} -> {:ok, {left, right}}
      _ -> {:error, "traversals are inconsistent"}
    end
  end
end

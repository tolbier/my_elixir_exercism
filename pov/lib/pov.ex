defmodule Pov do
  @moduledoc """
  Reorients a tree so that any of its nodes becomes the root.
  """

  @typedoc """
  A tree, which is made of a node with several branches
  """
  @type tree :: {any, [tree]}

  @doc """
  Reparent a tree on a selected node.

      iex> Pov.from_pov({:parent, [{:x, []}, {:sibling, []}]}, :x)
      {:ok, {:x, [{:parent, [{:sibling, []}]}]}}

      iex> Pov.from_pov({:parent, [{:x, []}]}, :nonexistent)
      {:error, :nonexistent_target}
  """
  @spec from_pov(tree(), any) :: {:ok, tree()} | {:error, :nonexistent_target}
  def from_pov(tree, target) do
    case reroot(tree, target, nil) do
      nil -> {:error, :nonexistent_target}
      rerooted -> {:ok, rerooted}
    end
  end

  @spec reroot(tree(), any, tree() | nil) :: tree() | nil
  defp reroot({target, branches}, target, parent), do: {target, prepend_parent(branches, parent)}

  defp reroot({value, branches}, target, parent) do
    Enum.find_value(branches, fn branch ->
      siblings = List.delete(branches, branch)
      reroot(branch, target, {value, prepend_parent(siblings, parent)})
    end)
  end

  @spec prepend_parent([tree()], tree() | nil) :: [tree()]
  defp prepend_parent(children, nil), do: children
  defp prepend_parent(children, parent), do: [parent | children]

  @doc """
  Finds a path between two nodes

      iex> Pov.path_between({:parent, [{:x, []}, {:sibling, []}]}, :x, :sibling)
      {:ok, [:x, :parent, :sibling]}

      iex> Pov.path_between({:parent, [{:x, []}]}, :x, :nonexistent)
      {:error, :nonexistent_destination}
  """
  @spec path_between(tree(), any, any) ::
          {:ok, [any]} | {:error, :nonexistent_source | :nonexistent_destination}
  def path_between(tree, from, to) do
    with {:ok, tree_from} <- from_pov(tree, from),
         path when is_list(path) <- path_to(tree_from, to) do
      {:ok, path}
    else
      {:error, :nonexistent_target} -> {:error, :nonexistent_source}
      nil -> {:error, :nonexistent_destination}
    end
  end

  @spec path_to(tree(), any) :: [any] | nil
  defp path_to({to, _branches}, to), do: [to]

  defp path_to({value, branches}, to) do
    Enum.find_value(branches, fn branch ->
      case path_to(branch, to) do
        nil -> nil
        path -> [value | path]
      end
    end)
  end
end

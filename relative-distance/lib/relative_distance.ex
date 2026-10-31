defmodule RelativeDistance do
  @moduledoc """
  Calculates degrees of separation between members of a family tree.
  """
  alias RelativeDistance.Dijkstra

  @type family_tree :: %{String.t() => [String.t()]}

  @doc """
  Find the degree of separation of two members given a given family tree.
  """
  @spec degree_of_separation(
          family_tree :: family_tree(),
          person_a :: String.t(),
          person_b :: String.t()
        ) :: nil | non_neg_integer()
  def degree_of_separation(family_tree, person_a, person_b) do
    graph = to_graph(family_tree)

    case Dijkstra.shortest_distance(graph, person_a, person_b) do
      {:ok, distance} -> distance
      _ -> nil
    end
  end

  @spec to_graph(family_tree()) :: Dijkstra.graph()
  defp to_graph(family_tree) do
    Enum.reduce(family_tree, %{}, fn {parent, children}, graph ->
      members = Enum.uniq([parent | children])

      Enum.reduce(members, graph, fn person, acc ->
        neighbors = members -- [person]
        Map.update(acc, person, neighbors, &Enum.uniq(&1 ++ neighbors))
      end)
    end)
  end

  defmodule Dijkstra do
    @moduledoc "Finds shortest distances in graphs with unit edge weights."

    @type graph :: %{String.t() => [String.t()]}
    @typep distances :: %{String.t() => non_neg_integer()}
    @typep visited :: %{String.t() => true}

    @spec shortest_distance(graph(), String.t(), String.t()) ::
            {:ok, non_neg_integer()} | :unreachable
    def shortest_distance(graph, person_a, person_b) do
      search(graph, %{person_a => 0}, %{}, person_b)
    end

    @spec search(graph(), distances(), visited(), String.t()) ::
            {:ok, non_neg_integer()} | :unreachable
    defp search(_graph, pending, _visited, _target) when map_size(pending) == 0,
      do: :unreachable

    defp search(graph, pending, visited, target) do
      closest = Enum.min_by(pending, fn {_person, cost} -> cost end)
      visit(graph, closest, pending, visited, target)
    end

    @spec visit(
            graph(),
            {String.t(), non_neg_integer()},
            distances(),
            visited(),
            String.t()
          ) :: {:ok, non_neg_integer()} | :unreachable
    defp visit(_graph, {person, distance}, _pending, _visited, person),
      do: {:ok, distance}

    defp visit(graph, {person, distance}, pending, visited, target) do
      visited = Map.put(visited, person, true)

      pending =
        pending
        |> Map.delete(person)
        |> update_distances(Map.get(graph, person, []), visited, distance)

      search(graph, pending, visited, target)
    end

    @spec update_distances(distances(), [String.t()], visited(), non_neg_integer()) ::
            distances()
    defp update_distances(pending, neighbors, visited, distance) do
      candidate = distance + 1

      Enum.reduce(neighbors, pending, fn neighbor, acc ->
        if Map.has_key?(visited, neighbor) do
          acc
        else
          Map.update(acc, neighbor, candidate, &min(&1, candidate))
        end
      end)
    end
  end
end

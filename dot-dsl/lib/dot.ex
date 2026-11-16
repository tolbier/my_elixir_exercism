defmodule Dot do
  @moduledoc """
  A small DSL that builds a `Graph` from DOT-like statements.
  """

  @spec graph(keyword) :: Macro.t()
  defmacro graph(do: block) do
    block
    |> statements()
    |> Enum.reduce(Graph.new(), &add_statement/2)
    |> Macro.escape()
  end

  defguardp is_node(id) when is_atom(id) and id != :graph

  @spec statements(Macro.t()) :: [Macro.t()]
  defp statements({:__block__, _, statements}), do: statements
  defp statements(statement), do: [statement]

  @spec add_statement(Macro.t(), Graph.t()) :: Graph.t()
  defp add_statement({:--, _, [{from, _, nil}, {to, _, nil}]}, graph)
       when is_node(from) and is_node(to),
       do: Graph.add_edge(graph, from, to)

  defp add_statement({:--, _, [{from, _, nil}, {to, _, [attrs]}]}, graph)
       when is_node(from) and is_node(to),
       do: Graph.add_edge(graph, from, to, attrs!(attrs))

  defp add_statement({:graph, _, [attrs]}, graph),
    do: Graph.put_attrs(graph, attrs!(attrs))

  defp add_statement({id, _, nil}, graph) when is_node(id),
    do: Graph.add_node(graph, id)

  defp add_statement({id, _, [attrs]}, graph) when is_node(id),
    do: Graph.add_node(graph, id, attrs!(attrs))

  defp add_statement(statement, _graph),
    do: raise(ArgumentError, "invalid statement: #{Macro.to_string(statement)}")

  @spec attrs!(term) :: keyword
  defp attrs!(attrs) do
    if Keyword.keyword?(attrs),
      do: attrs,
      else: raise(ArgumentError, "invalid attributes: #{Macro.to_string(attrs)}")
  end
end

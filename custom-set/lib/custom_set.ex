defmodule CustomSet do
  @moduledoc "A custom set implementation backed by a map."

  defstruct map: %{}
  @opaque t :: %__MODULE__{map: map}

  @spec new(Enum.t()) :: t
  def new(enumerable), do: %__MODULE__{map: Map.new(enumerable, &{&1, true})}

  @spec empty?(t) :: boolean
  def empty?(custom_set), do: Enum.empty?(custom_set.map)

  @spec contains?(t, any) :: boolean
  def contains?(custom_set, element), do: Map.has_key?(custom_set.map, element)

  @spec subset?(t, t) :: boolean
  def subset?(custom_set_1, custom_set_2),
    do: intersection(custom_set_1, custom_set_2) == custom_set_1

  @spec disjoint?(t, t) :: boolean
  def disjoint?(custom_set_1, custom_set_2), do: empty?(intersection(custom_set_1, custom_set_2))

  @spec equal?(t, t) :: boolean
  def equal?(custom_set_1, custom_set_2), do: custom_set_1 == custom_set_2

  @spec add(t, any) :: t
  def add(custom_set, element), do: %__MODULE__{map: Map.put(custom_set.map, element, true)}

  @spec intersection(t, t) :: t
  def intersection(custom_set_1, custom_set_2),
    do: %__MODULE__{map: Map.intersect(custom_set_1.map, custom_set_2.map)}

  @spec difference(t, t) :: t
  def difference(custom_set_1, custom_set_2),
    do: %__MODULE__{map: Map.drop(custom_set_1.map, Map.keys(custom_set_2.map))}

  @spec union(t, t) :: t
  def union(custom_set_1, custom_set_2),
    do: %__MODULE__{map: Map.merge(custom_set_1.map, custom_set_2.map)}
end

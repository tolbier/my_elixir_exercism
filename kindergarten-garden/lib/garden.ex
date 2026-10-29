defmodule Garden do
  @moduledoc """
  Determines each student's plants from the arrangement of cups on a windowsill.
  """

  @doc """
    Accepts a string representing the arrangement of cups on a windowsill and a
    list with names of students in the class. The student names list does not
    have to be in alphabetical order.

    It decodes that string into the various gardens for each student and returns
    that information in a map.
  """
  @all_names [
    :alice,
    :bob,
    :charlie,
    :david,
    :eve,
    :fred,
    :ginny,
    :harriet,
    :ileana,
    :joseph,
    :kincaid,
    :larry
  ]
  @plants %{
    ?G => :grass,
    ?C => :clover,
    ?R => :radishes,
    ?V => :violets
  }
  @spec info(String.t(), list) :: map
  def info(info_string, student_names \\ @all_names) do
    [row1, row2] =
      info_string
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&Enum.chunk_every(&1, 2))

    student_names
    |> Enum.sort()
    |> Enum.with_index()
    |> Map.new(fn {name, index} ->
      {name, plants_for(Enum.at(row1, index), Enum.at(row2, index))}
    end)
  end

  @spec plants_for(list | nil, list | nil) :: tuple
  defp plants_for(nil, nil), do: {}

  defp plants_for(first_row, second_row) do
    (first_row ++ second_row)
    |> Enum.map(&@plants[&1])
    |> List.to_tuple()
  end
end

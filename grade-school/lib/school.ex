defmodule School do
  @moduledoc """
  Simulate students in a school.

  Each student is in a grade.
  """

  defstruct students_by_grade: %{}, grade_by_student: %{}

  @type school :: %__MODULE__{
          students_by_grade: %{integer => [String.t()]},
          grade_by_student: %{String.t() => integer}
        }

  @doc """
  Create a new, empty school.
  """
  @spec new() :: school
  def new() do
    %__MODULE__{}
  end

  @doc """
  Add a student to a particular grade in school.
  """
  @spec add(school, String.t(), integer) :: {:ok | :error, school}
  def add(school, name, _grade) when school.grade_by_student |> is_map_key(name) do
    {:error, school}
  end

  def add(school, name, grade) do
    {:ok,
     %{
       school
       | grade_by_student: school.grade_by_student |> Map.put(name, grade),
         students_by_grade:
           school.students_by_grade
           |> Map.update(grade, [name], fn names -> Enum.sort([name | names]) end)
     }}
  end

  @doc """
  Return the names of the students in a particular grade, sorted alphabetically.
  """
  @spec grade(school, integer) :: [String.t()]
  def grade(school, grade), do: Map.get(school.students_by_grade, grade, [])

  @doc """
  Return the names of all the students in the school sorted by grade and name.
  """
  @spec roster(school) :: [String.t()]
  def roster(school) do
    school.students_by_grade
    |> Enum.sort_by(fn {grade, _names} -> grade end)
    |> Enum.flat_map(fn {_grade, names} -> names end)
  end
end

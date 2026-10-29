defmodule Matrix do
  @moduledoc """
  Parses, formats, and provides row/column access to a matrix of integers.
  """

  defstruct matrix: nil
  @type t :: %__MODULE__{matrix: [[integer]]}

  @doc """
  Convert an `input` string, with rows separated by newlines and values
  separated by single spaces, into a `Matrix` struct.
  """
  @spec from_string(input :: String.t()) :: t()
  def from_string(input) do
    %Matrix{
      matrix:
        input
        |> String.split("\n")
        |> Enum.map(fn row_str ->
          row_str
          |> String.split()
          |> Enum.map(&String.to_integer/1)
        end)
    }
  end

  @doc """
  Write the `matrix` out as a string, with rows separated by newlines and
  values separated by single spaces.
  """
  @spec to_string(matrix :: t()) :: String.t()
  def to_string(matrix) do
    matrix
    |> rows
    |> Enum.map_join("\n", fn row ->
      Enum.map_join(row, " ", &Integer.to_string/1)
    end)
  end

  @doc """
  Given a `matrix`, return its rows as a list of lists of integers.
  """
  @spec rows(matrix :: t()) :: list(list(integer))
  def rows(matrix) do
    matrix.matrix
  end

  @doc """
  Given a `matrix` and `index`, return the row at `index`.
  """
  @spec row(matrix :: t(), index :: integer) :: list(integer)
  def row(matrix, index) do
    matrix
    |> rows
    |> Enum.at(index - 1)
  end

  @doc """
  Given a `matrix`, return its columns as a list of lists of integers.
  """
  @spec columns(matrix :: t()) :: list(list(integer))
  def columns(matrix) do
    matrix
    |> rows
    |> Enum.zip_with(& &1)
  end

  @doc """
  Given a `matrix` and `index`, return the column at `index`.
  """
  @spec column(matrix :: t(), index :: integer) :: list(integer)
  def column(matrix, index) do
    matrix
    |> columns
    |> Enum.at(index - 1)
  end
end

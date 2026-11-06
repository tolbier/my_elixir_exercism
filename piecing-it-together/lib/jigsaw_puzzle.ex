defmodule JigsawPuzzle do
  @moduledoc """
  Fill in missing jigsaw puzzle details from partial data
  """

  @type format() :: :landscape | :portrait | :square
  @type t() :: %__MODULE__{
          pieces: pos_integer() | nil,
          rows: pos_integer() | nil,
          columns: pos_integer() | nil,
          format: format() | nil,
          aspect_ratio: float() | nil,
          border: pos_integer() | nil,
          inside: pos_integer() | nil
        }
  defguardp positive?(value) when is_number(value) and value > 0

  defstruct [:pieces, :rows, :columns, :format, :aspect_ratio, :border, :inside]
  @formats [:landscape, :portrait, :square]

  @spec data(t()) :: {:ok, t()} | {:error, String.t()}
  def data(puzzle),
    do:
      with(
        core = %__MODULE__{} <- infer_core(puzzle),
        do: compare(original: puzzle, completed: build(core))
      )

  @spec rows_and_columns(number(), number()) :: t()
  defp rows_and_columns(rows, columns),
    do: %__MODULE__{rows: trunc(rows), columns: trunc(columns)}

  @spec infer_core(%__MODULE__{rows: number() | nil, columns: number() | nil}) ::
          t() | {:error, String.t()}
  defp infer_core(puzzle \\ %__MODULE__{})

  defp infer_core(%__MODULE__{rows: rows, columns: columns})
       when positive?(rows) and positive?(columns),
       do: rows_and_columns(rows, columns)

  defp infer_core(%__MODULE__{pieces: pieces, aspect_ratio: aspect_ratio})
       when positive?(pieces) and positive?(aspect_ratio),
       do: rows_and_columns(:math.sqrt(pieces / aspect_ratio), :math.sqrt(pieces * aspect_ratio))

  defp infer_core(%__MODULE__{format: :square, rows: rows})
       when positive?(rows),
       do: rows_and_columns(rows, rows)

  defp infer_core(%__MODULE__{aspect_ratio: 1.0, inside: inside})
       when positive?(inside) do
    rows = trunc(:math.sqrt(inside)) + 2
    rows_and_columns(rows, rows)
  end

  defp infer_core(%__MODULE__{aspect_ratio: aspect_ratio, rows: rows})
       when positive?(aspect_ratio) and positive?(rows),
       do: rows_and_columns(rows, rows * aspect_ratio)

  defp infer_core(%__MODULE__{format: format, pieces: pieces, border: border})
       when format in @formats and positive?(pieces) and positive?(border),
       do:
         (case {Enum.sort(roots(2, -border - 4, pieces * 2)), format} do
            {[rows], :square} -> rows_and_columns(rows, rows)
            {[columns, rows], :portrait} -> rows_and_columns(rows, columns)
            {[rows, columns], :landscape} -> rows_and_columns(rows, columns)
            _ -> infer_core()
          end)

  defp infer_core(_puzzle), do: {:error, "Insufficient data"}

  @spec build(t()) :: t()
  defp build(%__MODULE__{rows: rows, columns: columns}) do
    pieces = rows * columns
    aspect_ratio = columns / rows
    border = 2 * rows + 2 * columns - 4

    %__MODULE__{
      rows: rows,
      columns: columns,
      pieces: pieces,
      aspect_ratio: aspect_ratio,
      format: format(aspect_ratio),
      border: border,
      inside: pieces - border
    }
  end

  @spec format(number()) :: format()
  defp format(1.0), do: :square
  defp format(aspect_ratio) when aspect_ratio > 1.0, do: :landscape
  defp format(_), do: :portrait

  @spec compare(original: t(), completed: t()) :: {:ok, t()} | {:error, String.t()}
  defp compare(original: %__MODULE__{} = original, completed: %__MODULE__{} = completed),
    do:
      if(
        original
        |> Map.from_struct()
        |> Enum.all?(fn {field, value} ->
          is_nil(value) or value == Map.fetch!(completed, field)
        end),
        do: {:ok, completed},
        else: {:error, "Contradictory data"}
      )

  @spec roots(number(), number(), number()) :: [float()]
  defp roots(a, b, c) when a != 0 do
    discriminant = b * b - 4 * a * c
    roots(a, b, c, discriminant)
  end

  @spec roots(number(), number(), number(), number()) :: [float()]
  defp roots(a, b, _c, discriminant) when discriminant == 0, do: [-b / (2 * a)]
  defp roots(_a, _b, _c, discriminant) when discriminant < 0, do: []

  defp roots(a, b, _c, discriminant) do
    root = :math.sqrt(discriminant)
    [(-b + root) / (2 * a), (-b - root) / (2 * a)]
  end
end

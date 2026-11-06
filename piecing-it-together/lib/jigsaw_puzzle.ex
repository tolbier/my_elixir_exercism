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

  @spec data(jigsaw_puzzle :: JigsawPuzzle.t()) ::
          {:ok, JigsawPuzzle.t()} | {:error, String.t()}
  def data(puzzle),
    do:
      with(
        core = %__MODULE__{} <- infer_core(puzzle),
        do:
          compare(
            original: puzzle,
            completed: build(core)
          )
      )

  @spec infer_core(t()) :: t() | {:error, String.t()}

  defp infer_core(%__MODULE__{
         pieces: pieces,
         aspect_ratio: aspect_ratio
       })
       when positive?(pieces) and positive?(aspect_ratio),
       do: %__MODULE__{
         pieces: pieces,
         aspect_ratio: aspect_ratio
       }

  defp infer_core(%__MODULE__{
         format: :square,
         rows: rows
       })
       when positive?(rows),
       do: infer_core(%__MODULE__{aspect_ratio: 1.0, pieces: rows * rows})

  defp infer_core(%__MODULE__{
         aspect_ratio: 1.0,
         inside: inside
       })
       when positive?(inside),
       do: infer_core(%__MODULE__{format: :square, rows: trunc(:math.sqrt(inside)) + 2})

  defp infer_core(%__MODULE__{
         columns: columns,
         rows: rows
       })
       when positive?(columns) and positive?(rows),
       do:
         infer_core(%__MODULE__{
           pieces: columns * rows,
           aspect_ratio: columns / rows
         })

  defp infer_core(%__MODULE__{
         aspect_ratio: aspect_ratio,
         rows: rows
       })
       when positive?(aspect_ratio) and positive?(rows),
       do:
         infer_core(%__MODULE__{
           rows: rows,
           columns: rows * aspect_ratio
         })

  defp infer_core(%__MODULE__{
         format: format,
         pieces: pieces,
         border: border
       })
       when format in @formats and positive?(pieces) and positive?(border),
       do:
         (case {Enum.sort(quadratic_roots(2, -border - 4, pieces * 2)), format} do
            {[rows], :square} ->
              infer_core(%__MODULE__{format: :square, rows: rows})

            {[columns, rows], :portrait} ->
              infer_core(%__MODULE__{rows: rows, columns: columns})

            {[rows, columns], :landscape} ->
              infer_core(%__MODULE__{rows: rows, columns: columns})

            _ ->
              {:error, "Insufficient data"}
          end)

  defp infer_core(_puzzle), do: {:error, "Insufficient data"}

  @spec build(t()) :: t()
  defp build(%__MODULE__{pieces: pieces, aspect_ratio: aspect_ratio}),
    do:
      build(
        trunc(:math.sqrt(pieces / aspect_ratio)),
        trunc(:math.sqrt(pieces * aspect_ratio))
      )

  @spec build(integer(), integer()) :: t()
  defp build(rows, columns) do
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

  @spec quadratic_roots(number(), number(), number()) :: [float()]
  defp quadratic_roots(a, b, c) when a != 0 do
    discriminant = b * b - 4 * a * c

    cond do
      discriminant < 0 ->
        []

      discriminant == 0 ->
        [-b / (2 * a)]

      discriminant > 0 ->
        root = :math.sqrt(discriminant)
        [(-b + root) / (2 * a), (-b - root) / (2 * a)]
    end
  end
end

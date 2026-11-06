defmodule JigsawPuzzle do
  @doc """
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
  def data(puzzle) do
    with core = %__MODULE__{} <- infer_core(puzzle) do
      compare(
        original: puzzle,
        completed: build(pieces: core.pieces, aspect_ratio: core.aspect_ratio)
      )
    end
  end

  def infer_core(puzzle \\ nil)

  def infer_core(%__MODULE__{
        pieces: pieces,
        aspect_ratio: aspect_ratio
      })
      when positive?(pieces) and positive?(aspect_ratio) do
    %__MODULE__{
      pieces: pieces,
      aspect_ratio: aspect_ratio
    }
  end

  def infer_core(%__MODULE__{
        format: :square,
        rows: rows
      })
      when positive?(rows),
      do: infer_core(%__MODULE__{aspect_ratio: 1.0, pieces: rows * rows})

  def infer_core(%__MODULE__{
        aspect_ratio: 1.0,
        inside: inside
      })
      when positive?(inside),
      do: infer_core(%__MODULE__{format: :square, rows: trunc(:math.sqrt(inside)) + 2})

  def infer_core(%__MODULE__{
        columns: columns,
        rows: rows
      })
      when positive?(columns) and positive?(rows),
      do:
        infer_core(%__MODULE__{
          pieces: columns * rows,
          aspect_ratio: columns / rows
        })

  def infer_core(%__MODULE__{
        aspect_ratio: aspect_ratio,
        rows: rows
      })
      when positive?(aspect_ratio) and positive?(rows),
      do:
        infer_core(%__MODULE__{
          rows: rows,
          columns: rows * aspect_ratio
        })

  def infer_core(%__MODULE__{
        format: format,
        pieces: pieces,
        border: border
      })
      when format in @formats and positive?(pieces) and positive?(border) do
    case {Enum.sort(quadratic_roots(2, -border - 4, pieces * 2)), format} do
      {[rows], :square} ->
        infer_core(%__MODULE__{format: :square, rows: rows})

      {[columns, rows], :portrait} ->
        infer_core(%__MODULE__{rows: rows, columns: columns})

      {[rows, columns], :landscape} ->
        infer_core(%__MODULE__{rows: rows, columns: columns})

      _ ->
        infer_core()
    end
  end

  def infer_core(_puzzle), do: {:error, "Insufficient data"}

  def build(pieces: pieces, aspect_ratio: aspect_ratio) do
    build(%__MODULE__{
      rows: trunc(:math.sqrt(pieces / aspect_ratio)),
      columns: trunc(:math.sqrt(pieces * aspect_ratio))
    })
  end

  def build(puzzle = %__MODULE__{columns: columns, rows: rows, pieces: nil}) do
    build(%{puzzle | pieces: columns * rows})
  end

  def build(puzzle = %__MODULE__{columns: columns, rows: rows, aspect_ratio: nil}) do
    build(%{puzzle | aspect_ratio: columns / rows})
  end

  def build(puzzle = %__MODULE__{aspect_ratio: aspect_ratio, format: nil}) do
    build(%{puzzle | format: format(aspect_ratio)})
  end

  def build(puzzle = %__MODULE__{columns: columns, rows: rows, border: nil}) do
    build(%{puzzle | border: border(rows, columns)})
  end

  def build(puzzle = %__MODULE__{columns: columns, rows: rows, inside: nil}) do
    build(%{puzzle | inside: inside(rows, columns)})
  end

  def build(puzzle = %__MODULE__{}), do: puzzle

  def format(1.0), do: :square
  def format(aspect_ratio) when aspect_ratio > 1.0, do: :landscape
  def format(_), do: :portrait

  def border(rows, cols), do: 2 * rows + 2 * cols - 4
  def inside(rows, cols), do: rows * cols - border(rows, cols)

  @spec compare(original: t(), completed: t()) :: {:ok, t()} | {:error, String.t()}
  defp compare(original: %__MODULE__{} = original, completed: %__MODULE__{} = completed) do
    if original
       |> Map.from_struct()
       |> Enum.all?(fn {field, value} ->
         is_nil(value) or value == Map.fetch!(completed, field)
       end) do
      {:ok, completed}
    else
      {:error, "Contradictory data"}
    end
  end

  @spec quadratic_roots(number(), number(), number()) :: [float()]
  def quadratic_roots(a, b, c) when a != 0 do
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

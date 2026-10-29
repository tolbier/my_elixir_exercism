defmodule OcrNumbers do
  @moduledoc """
  Converts OCR digit grids into numbers.
  """

  @doc """
  Given a 3 x 4 grid of pipes, underscores, and spaces, determine which number is represented, or
  whether it is garbled.
  """
  @spec convert([String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  def convert(input)
      when rem(length(input), 4) != 0, do: {:error, "invalid line count"}

  def convert([row0, row1, row2, row3 | _rest])
      when rem(byte_size(row0), 3) != 0 or
             rem(byte_size(row1), 3) != 0 or
             rem(byte_size(row2), 3) != 0 or
             rem(byte_size(row3), 3) != 0 do
    {:error, "invalid column count"}
  end

  def convert([]), do: {:ok, ""}

  def convert([
        "   ",
        "  |",
        "  |",
        "   "
      ]),
      do: {:ok, "1"}

  def convert([
        " _ ",
        " _|",
        "|_ ",
        "   "
      ]),
      do: {:ok, "2"}

  def convert([
        " _ ",
        " _|",
        " _|",
        "   "
      ]),
      do: {:ok, "3"}

  def convert([
        "   ",
        "|_|",
        "  |",
        "   "
      ]),
      do: {:ok, "4"}

  def convert([
        " _ ",
        "|_ ",
        " _|",
        "   "
      ]),
      do: {:ok, "5"}

  def convert([
        " _ ",
        "|_ ",
        "|_|",
        "   "
      ]),
      do: {:ok, "6"}

  def convert([
        " _ ",
        "  |",
        "  |",
        "   "
      ]),
      do: {:ok, "7"}

  def convert([
        " _ ",
        "|_|",
        "|_|",
        "   "
      ]),
      do: {:ok, "8"}

  def convert([
        " _ ",
        "|_|",
        " _|",
        "   "
      ]),
      do: {:ok, "9"}

  def convert([
        " _ ",
        "| |",
        "|_|",
        "   "
      ]),
      do: {:ok, "0"}

  def convert([
        "",
        "",
        "",
        ""
      ]),
      do: {:ok, ""}

  def convert([
        <<_::binary-size(3)>>,
        <<_::binary-size(3)>>,
        <<_::binary-size(3)>>,
        <<_::binary-size(3)>>
      ]),
      do: {:ok, "?"}

  def convert([
        <<row0::binary-size(3), row0_rest::binary>>,
        <<row1::binary-size(3), row1_rest::binary>>,
        <<row2::binary-size(3), row2_rest::binary>>,
        <<row3::binary-size(3), row3_rest::binary>> | rest
      ]) do
    with {:ok, value_row} <- convert([row0, row1, row2, row3]),
         {:ok, value_row_rest} <- convert([row0_rest, row1_rest, row2_rest, row3_rest]),
         {:ok, value_rest} <- convert(rest) do
      {:ok, value_row <> value_row_rest <> format_value_rest(value_rest)}
    end
  end

  defp format_value_rest(""), do: ""
  defp format_value_rest(value_rest), do: ",#{value_rest}"
end

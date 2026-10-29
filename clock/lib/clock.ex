defmodule Clock do
  @moduledoc "A clock that wraps hours and minutes to a 24-hour format."

  @type t() :: %__MODULE__{hour: integer, minute: integer}
  defstruct hour: 0, minute: 0

  defimpl String.Chars do
    @spec to_string(Clock.t()) :: String.t()
    def to_string(%Clock{hour: hour, minute: minute}) do
      pad = &String.pad_leading(Integer.to_string(&1), 2, "0")
      "#{pad.(hour)}:#{pad.(minute)}"
    end
  end

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: t()
  def new(hour, minute),
    do: %Clock{
      hour: Integer.mod(hour + Integer.floor_div(minute, 60), 24),
      minute: Integer.mod(minute, 60)
    }

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(t(), integer) :: t()
  def add(%Clock{hour: hour, minute: minute}, add_minute) do
    new(hour, minute + add_minute)
  end
end

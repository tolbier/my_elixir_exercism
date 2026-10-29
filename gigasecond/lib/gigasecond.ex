defmodule Gigasecond do
  @moduledoc """
  Calculate the date one billion (giga) seconds after a given date.
  """

  @doc """
  Calculate a date one billion seconds after an input date.
  """
  @spec from(:calendar.datetime()) :: :calendar.datetime()
  def from(datetime) do
    datetime
    |> :calendar.datetime_to_gregorian_seconds()
    |> Kernel.+(1_000_000_000)
    |> :calendar.gregorian_seconds_to_datetime()
  end
end

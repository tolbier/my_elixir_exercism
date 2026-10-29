defmodule Meetup do
  @moduledoc """
  Calculate meetup dates.
  """

  @type weekday ::
          :monday
          | :tuesday
          | :wednesday
          | :thursday
          | :friday
          | :saturday
          | :sunday

  @type schedule :: :first | :second | :third | :fourth | :last | :teenth

  @weekdays %{monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6}
  @schedules %{first: 0, second: 1, third: 2, fourth: 3, last: -1}
  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: Date.t()
  def meetup(year, month, weekday, schedule) do
    1..31
    |> valid_dates(year, month)
    |> filter_dates_by_weekday(weekday)
    |> schedule_date(schedule)
  end

  @spec filter_dates_by_weekday([Date.t()], weekday) :: [Date.t()]
  defp filter_dates_by_weekday(dates, weekday) do
    dates |> Enum.filter(&date_is_weekday?(&1, weekday))
  end

  @spec schedule_date([Date.t()], schedule) :: Date.t()
  defp schedule_date(dates, :teenth),
    do: Enum.find(dates, fn date -> date.day >= 13 and date.day <= 19 end)

  defp schedule_date(dates, schedule), do: Enum.at(dates, @schedules[schedule])

  @spec date_is_weekday?(Date.t(), weekday) :: boolean
  defp date_is_weekday?(date, weekday) do
    date |> day_of_week() == @weekdays[weekday]
  end

  @spec valid_dates(Enumerable.t(pos_integer), pos_integer, pos_integer) :: [Date.t()]
  defp valid_dates(days, year, month) do
    for(
      day <- days,
      {:ok, date} <- [Date.new(year, month, day)],
      do: date
    )
  end

  @spec day_of_week(Date.t()) :: non_neg_integer
  defp day_of_week(date) do
    Date.day_of_week(date) - 1
  end
end

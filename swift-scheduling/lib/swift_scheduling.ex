defmodule SwiftScheduling do
  @moduledoc "Converts abbreviated delivery descriptions into delivery dates."

  @days [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  @day_numbers @days |> Enum.with_index(1) |> Map.new()

  @type weekday ::
          :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @typep postponement ::
           [after_hours: integer()]
           | [after_days: integer(), hour: 0..23]
           | [weekday: weekday(), hour: 0..23]
           | [month: 1..12]
           | [quarter: 1..4]

  @doc """
  Convert delivery date descriptions to actual delivery dates, based on when the meeting started.
  """
  @spec delivery_date(NaiveDateTime.t(), String.t()) :: NaiveDateTime.t()
  def delivery_date(meeting_date, "NOW") do
    postpone_to(meeting_date, after_hours: 2)
  end

  def delivery_date(%NaiveDateTime{hour: hour} = meeting_date, "ASAP") when hour < 13 do
    postpone_to(meeting_date, after_days: 0, hour: 17)
  end

  def delivery_date(meeting_date, "ASAP") do
    postpone_to(meeting_date, after_days: 1, hour: 13)
  end

  def delivery_date(meeting_date, <<digit, "M">>) when digit in ?1..?9 do
    postpone_to(meeting_date, month: digit - ?0)
  end

  def delivery_date(meeting_date, <<"1", digit, "M">>) when digit in ?0..?2 do
    postpone_to(meeting_date, month: 10 + digit - ?0)
  end

  def delivery_date(meeting_date, <<"Q", digit>>) when digit in ?1..?4 do
    postpone_to(meeting_date, quarter: digit - ?0)
  end

  def delivery_date(meeting_date, "EOW") do
    end_of_week(meeting_date, weekday(meeting_date))
  end

  @spec weekday(NaiveDateTime.t()) :: weekday()
  defp weekday(meeting_date) do
    Enum.fetch!(@days, Date.day_of_week(meeting_date) - 1)
  end

  @spec end_of_week(NaiveDateTime.t(), weekday()) :: NaiveDateTime.t()
  defp end_of_week(meeting_date, weekday) when weekday in [:monday, :tuesday, :wednesday] do
    postpone_to(meeting_date, weekday: :friday, hour: 17)
  end

  defp end_of_week(meeting_date, _weekday) do
    postpone_to(meeting_date, weekday: :sunday, hour: 20)
  end

  @spec postpone_to(NaiveDateTime.t(), postponement()) :: NaiveDateTime.t()
  defp postpone_to(meeting_date, after_hours: after_hours) do
    NaiveDateTime.add(meeting_date, after_hours, :hour)
  end

  defp postpone_to(meeting_date, after_days: after_days, hour: hour) do
    %{
      NaiveDateTime.add(meeting_date, after_days, :day)
      | hour: hour,
        minute: 0,
        second: 0,
        microsecond: {0, 0}
    }
  end

  defp postpone_to(meeting_date, weekday: weekday, hour: hour) do
    target_weekday = Map.fetch!(@day_numbers, weekday)
    meeting_weekday = Date.day_of_week(meeting_date)
    days_until_target = Integer.mod(target_weekday - meeting_weekday, 7)

    postpone_to(meeting_date, after_days: days_until_target, hour: hour)
  end

  defp postpone_to(%NaiveDateTime{year: year, month: meeting_month}, month: month) do
    target_year = if meeting_month < month, do: year, else: year + 1

    NaiveDateTime.new!(target_year, month, 1, 8, 0, 0)
    |> first_workday_on_or_after()
  end

  defp postpone_to(%NaiveDateTime{year: year, month: meeting_month}, quarter: quarter) do
    target_year = if quarter(meeting_month) <= quarter, do: year, else: year + 1

    last_workday_in(year: target_year, quarter: quarter)
  end

  @spec quarter(1..12) :: 1..4
  defp quarter(month), do: div(month - 1, 3) + 1

  @spec last_workday_in(year: integer(), quarter: 1..4) :: NaiveDateTime.t()
  defp last_workday_in(year: year, quarter: quarter) do
    last_day = year |> Date.new!(quarter * 3, 1) |> Date.end_of_month()
    days_back = max(Date.day_of_week(last_day) - 5, 0)

    last_day
    |> Date.add(-days_back)
    |> NaiveDateTime.new!(~T[08:00:00])
  end

  @spec first_workday_on_or_after(NaiveDateTime.t()) :: NaiveDateTime.t()
  defp first_workday_on_or_after(datetime) do
    weekday = Date.day_of_week(datetime)
    NaiveDateTime.add(datetime, days_to_next_workday(weekday), :day)
  end

  @spec days_to_next_workday(1..7) :: 0..2
  defp days_to_next_workday(weekday) do
    case weekday do
      7 -> 1
      6 -> 2
      _ -> 0
    end
  end
end

defmodule LibraryFees do
  def datetime_from_string(string), do: string |> NaiveDateTime.from_iso8601!()

  def before_noon?(datetime), do: datetime.hour < 12

  def return_date(checkout_datetime) do
    days = if before_noon?(checkout_datetime), do: 28, else: 29

    checkout_datetime
    |> NaiveDateTime.add(days, :day)
    |> NaiveDateTime.to_date()
  end

  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> NaiveDateTime.to_date()
    |> Date.diff(planned_return_date)
    |> max(0)
  end

  def monday?(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Date.day_of_week() == 1
  end

  def calculate_late_fee(checkout, return, rate) do
    checkout_datetime = datetime_from_string(checkout)
    actual_return_datetime = datetime_from_string(return)

    days =
      checkout_datetime
      |> return_date()
      |> days_late(actual_return_datetime)

    fee = days * rate

    if monday?(actual_return_datetime), do: trunc(fee * 0.5), else: fee
  end
end

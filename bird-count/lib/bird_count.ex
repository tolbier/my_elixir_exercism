defmodule BirdCount do
  def today([]), do: nil
  def today([day | _]), do: day

  def increment_day_count([]), do: [1]
  def increment_day_count([day | rest]), do: [day + 1 | rest]

  def has_day_without_birds?([]), do: false

  def has_day_without_birds?([day | rest]) do
    day == 0 or
      has_day_without_birds?(rest)
  end

  def total([]), do: 0
  def total([day | rest]), do: day + total(rest)

  def busy_days([]), do: 0
  def busy_days([day | rest]) when day >= 5, do: 1 + busy_days(rest)
  def busy_days([_ | rest]), do: busy_days(rest)
end

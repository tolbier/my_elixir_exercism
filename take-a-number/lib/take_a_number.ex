defmodule TakeANumber do
  def start() do
    spawn(&loop/0)
  end

  defp loop(value \\ 0) do
    receive do
      {:report_state, caller} ->
        send(caller, value)
        loop(value)

      {:take_a_number, caller} ->
        new_value = value + 1
        send(caller, new_value)
        loop(new_value)

      :stop ->
        :ok

      _ ->
        loop(value)
    end
  end
end

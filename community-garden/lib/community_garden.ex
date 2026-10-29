# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(_opts \\ []) do
    Agent.start(fn -> {%{}, 1} end)
  end

  def list_registrations(pid) do
    pid
    |> Agent.get(fn {map, _} -> map end)
    |> Enum.sort()
    |> Enum.map(fn {_key, value} -> value end)
  end

  def register(pid, register_to) do
    pid
    |> Agent.get_and_update(fn {map, next_plot_id} ->
      new_plot = %Plot{plot_id: next_plot_id, registered_to: register_to}

      new_state = {
        Map.put(map, next_plot_id, new_plot),
        next_plot_id + 1
      }

      {new_plot, new_state}
    end)
  end

  def release(pid, plot_id) do
    pid
    |> Agent.get_and_update(fn {map, next_plot_id} ->
      new_map = Map.delete(map, plot_id)
      new_state = {new_map, next_plot_id}
      {:ok, new_state}
    end)
  end

  def get_registration(pid, plot_id) do
    case pid |> Agent.get(fn {map, _} -> map |> Map.fetch(plot_id) end) do
      {:ok, plot} -> plot
      :error -> {:not_found, "plot is unregistered"}
    end
  end
end

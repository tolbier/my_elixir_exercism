defmodule React do
  @moduledoc """
  A reactive system of input cells and computed output cells with change callbacks.
  """

  @opaque cells :: pid

  @type cell :: {:input, String.t(), any} | {:output, String.t(), [String.t()], fun()}
  @type callback :: (callback_name :: String.t(), value :: any -> any)

  # Current value of every cell, by name
  @typep values :: %{String.t() => any}
  # Callbacks of each output cell, by cell name and then by callback name
  @typep callbacks :: %{String.t() => %{String.t() => callback()}}
  # The cell definitions are kept to recompute the values when an input changes
  @typep state :: %{definitions: [cell], values: values(), callbacks: callbacks()}
  @typep pending_callback :: {callback(), callback_name :: String.t(), value :: any}

  @doc """
  Start a reactive system
  """
  @spec new(cells :: [cell]) :: {:ok, cells()}
  def new(cells), do: Agent.start_link(fn -> init(cells) end)

  @spec init([cell]) :: state()
  defp init(cells), do: %{definitions: cells, values: compute_values(cells), callbacks: %{}}

  # Each cell is listed after the cells it depends on, so a single pass in
  # order can compute every value.
  @spec compute_values([cell]) :: values()
  defp compute_values(cells), do: Enum.reduce(cells, %{}, &put_cell_value/2)

  @spec put_cell_value(cell, values()) :: values()
  defp put_cell_value({:input, name, value}, values), do: Map.put(values, name, value)

  defp put_cell_value({:output, name, inputs, compute}, values) do
    input_values = Enum.map(inputs, &Map.fetch!(values, &1))
    Map.put(values, name, apply(compute, input_values))
  end

  @doc """
  Return the value of an input or output cell
  """
  @spec get_value(cells :: cells(), cell_name :: String.t()) :: any()
  def get_value(cells, cell_name), do: Agent.get(cells, &Map.fetch!(&1.values, cell_name))

  @doc """
  Set the value of an input cell
  """
  @spec set_value(cells :: cells(), cell_name :: String.t(), value :: any) :: :ok
  def set_value(cells, cell_name, value) do
    cells
    |> Agent.get_and_update(&update_input(&1, cell_name, value))
    |> Enum.each(&run_callback/1)
  end

  # Callbacks run in the caller, so a slow or failing one never blocks the agent
  @spec run_callback(pending_callback()) :: any
  defp run_callback({callback, callback_name, value}), do: callback.(callback_name, value)

  @spec update_input(state(), String.t(), any) :: {[pending_callback()], state()}
  defp update_input(state, name, value) do
    new_state = put_input(state, name, value)
    {pending_callbacks(state, new_state), new_state}
  end

  @spec put_input(state(), String.t(), any) :: state()
  defp put_input(state = %{definitions: definitions}, name, value) do
    definitions = Enum.map(definitions, &replace_input(&1, name, value))
    %{state | definitions: definitions, values: compute_values(definitions)}
  end

  @spec replace_input(cell, String.t(), any) :: cell
  defp replace_input({:input, name, _old_value}, name, value), do: {:input, name, value}
  defp replace_input(cell, _name, _value), do: cell

  # Callbacks to run, with their arguments, for the cells whose value changed.
  # Both states are stable, so each changed cell is reported once.
  @spec pending_callbacks(state(), state()) :: [pending_callback()]
  defp pending_callbacks(%{values: old_values}, %{values: new_values, callbacks: callbacks}) do
    for {cell_name, cell_callbacks} <- callbacks,
        new_value = Map.fetch!(new_values, cell_name),
        new_value !== Map.fetch!(old_values, cell_name),
        {callback_name, callback} <- cell_callbacks,
        do: {callback, callback_name, new_value}
  end

  @doc """
  Add a callback to an output cell
  """
  @spec add_callback(
          cells :: cells(),
          cell_name :: String.t(),
          callback_name :: String.t(),
          callback :: callback()
        ) :: :ok
  def add_callback(cells, cell_name, callback_name, callback),
    do: Agent.update(cells, &put_callback(&1, cell_name, callback_name, callback))

  @spec put_callback(state(), String.t(), String.t(), callback()) :: state()
  defp put_callback(state, cell_name, callback_name, callback),
    do: put_in(state, [:callbacks, Access.key(cell_name, %{}), callback_name], callback)

  @doc """
  Remove a callback from an output cell
  """
  @spec remove_callback(cells :: cells(), cell_name :: String.t(), callback_name :: String.t()) ::
          :ok
  def remove_callback(cells, cell_name, callback_name),
    do: Agent.update(cells, &delete_callback(&1, cell_name, callback_name))

  # Removing a callback that is not registered leaves the state unchanged
  @spec delete_callback(state(), String.t(), String.t()) :: state()
  defp delete_callback(state, cell_name, callback_name),
    do: update_in(state, [:callbacks, Access.key(cell_name, %{})], &Map.delete(&1, callback_name))
end

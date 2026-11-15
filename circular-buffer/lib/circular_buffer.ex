defmodule CircularBuffer do
  @moduledoc """
  An API to a stateful process that fills and empties a circular buffer
  """

  # `read` and `write` point to the same slot both when the buffer is empty and
  # when it is full; `size` tells the two cases apart.
  defstruct data: {}, read: 0, write: 0, size: 0

  # State kept by the Agent. The capacity is `tuple_size(data)`.
  @typep state :: %__MODULE__{
           data: tuple,
           read: non_neg_integer,
           write: non_neg_integer,
           size: non_neg_integer
         }

  defguardp is_empty(state) when state.size == 0
  defguardp is_full(state) when state.size == tuple_size(state.data)

  @doc """
  Create a new buffer of a given capacity
  """
  @spec new(capacity :: pos_integer) :: {:ok, pid}
  def new(capacity),
    do: Agent.start_link(fn -> %__MODULE__{data: Tuple.duplicate(nil, capacity)} end)

  @doc """
  Read the oldest entry in the buffer, fail if it is empty
  """
  @spec read(buffer :: pid) :: {:ok, any} | {:error, :empty}
  def read(buffer) do
    Agent.get_and_update(buffer, fn
      state when is_empty(state) -> {{:error, :empty}, state}
      state -> {{:ok, elem(state.data, state.read)}, drop_oldest(state)}
    end)
  end

  @doc """
  Write a new item in the buffer, fail if it is full
  """
  @spec write(buffer :: pid, item :: any) :: :ok | {:error, :full}
  def write(buffer, item) do
    Agent.get_and_update(buffer, fn
      state when is_full(state) -> {{:error, :full}, state}
      state -> {:ok, push(state, item)}
    end)
  end

  @doc """
  Write an item in the buffer, overwrite the oldest entry if it is full
  """
  @spec overwrite(buffer :: pid, item :: any) :: :ok
  def overwrite(buffer, item) do
    Agent.update(buffer, fn
      state when is_full(state) -> state |> drop_oldest() |> push(item)
      state -> push(state, item)
    end)
  end

  @doc """
  Clear the buffer
  """
  @spec clear(buffer :: pid) :: :ok
  def clear(buffer),
    do: Agent.update(buffer, fn state -> %{state | read: 0, write: 0, size: 0} end)

  @spec push(state(), any) :: state()
  defp push(state, item) do
    %{
      state
      | data: put_elem(state.data, state.write, item),
        write: next_index(state, state.write),
        size: state.size + 1
    }
  end

  # The slot is not cleared: it can no longer be read, and the next push that
  # reaches it replaces the value.
  @spec drop_oldest(state()) :: state()
  defp drop_oldest(state),
    do: %{state | read: next_index(state, state.read), size: state.size - 1}

  @spec next_index(state(), non_neg_integer) :: non_neg_integer
  defp next_index(state, index), do: rem(index + 1, tuple_size(state.data))
end

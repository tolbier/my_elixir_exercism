defmodule SplitSecondStopwatch do
  @moduledoc """
  A stopwatch that can be used to track lap times.
  """

  @type state :: :ready | :running | :stopped

  defmodule Stopwatch do
    @moduledoc """
    The stopwatch's state: current status, current lap time, and previous lap times.
    """

    @type t :: %__MODULE__{
            state: SplitSecondStopwatch.state(),
            current_lap: Time.t(),
            previous_laps: [Time.t()]
          }
    @time_zero ~T[00:00:00]
    defstruct state: :ready, current_lap: @time_zero, previous_laps: []

    @spec state(t()) :: SplitSecondStopwatch.state()
    def state(stopwatch), do: stopwatch.state

    @spec current_lap(t()) :: Time.t()
    def current_lap(stopwatch), do: stopwatch.current_lap

    @spec previous_laps(t()) :: [Time.t()]
    def previous_laps(stopwatch), do: stopwatch.previous_laps

    @spec total(t()) :: Time.t()
    def total(%__MODULE__{current_lap: current, previous_laps: laps}),
      do: sum_times([current | laps])

    @spec advance_time(t(), Time.t()) :: t()
    def advance_time(stopwatch = %__MODULE__{current_lap: current, state: :running}, time) do
      %{stopwatch | current_lap: sum_times([current, time])}
    end

    def advance_time(stopwatch = %__MODULE__{}, _), do: stopwatch

    @spec sum_times([Time.t()]) :: Time.t()
    defp sum_times(times) do
      times
      |> Enum.map(fn time -> elem(Time.to_seconds_after_midnight(time), 0) end)
      |> Enum.sum()
      |> Time.from_seconds_after_midnight()
    end

    @spec start(t()) :: t() | {:error, String.t()}
    def start(%__MODULE__{state: :running}),
      do: {:error, "cannot start an already running stopwatch"}

    def start(stopwatch = %__MODULE__{}),
      do: %{stopwatch | state: :running}

    @spec stop(t()) :: t() | {:error, String.t()}
    def stop(stopwatch = %__MODULE__{state: :running}),
      do: %{stopwatch | state: :stopped}

    def stop(%__MODULE__{}),
      do: {:error, "cannot stop a stopwatch that is not running"}

    @spec lap(t()) :: t() | {:error, String.t()}
    def lap(stopwatch = %__MODULE__{state: :running, current_lap: current, previous_laps: laps}),
      do: %{stopwatch | previous_laps: laps ++ [current], current_lap: @time_zero}

    def lap(%__MODULE__{}),
      do: {:error, "cannot lap a stopwatch that is not running"}

    @spec reset(t()) :: t() | {:error, String.t()}
    def reset(%__MODULE__{state: :stopped}), do: %__MODULE__{}

    def reset(%__MODULE__{}),
      do: {:error, "cannot reset a stopwatch that is not stopped"}
  end

  @spec new() :: Stopwatch.t()
  def new() do
    %Stopwatch{}
  end

  @doc "Returns the stopwatch's current state."
  @spec state(Stopwatch.t()) :: state()
  def state(stopwatch), do: Stopwatch.state(stopwatch)

  @doc "Returns the elapsed time of the current lap."
  @spec current_lap(Stopwatch.t()) :: Time.t()
  def current_lap(stopwatch), do: Stopwatch.current_lap(stopwatch)

  @doc "Returns the list of previously recorded lap times."
  @spec previous_laps(Stopwatch.t()) :: [Time.t()]
  def previous_laps(stopwatch), do: Stopwatch.previous_laps(stopwatch)

  @doc "Advances the stopwatch's tracked time by the given amount."
  @spec advance_time(Stopwatch.t(), Time.t()) :: Stopwatch.t()
  def advance_time(stopwatch, time), do: Stopwatch.advance_time(stopwatch, time)

  @doc "Returns the total elapsed time, current lap included."
  @spec total(Stopwatch.t()) :: Time.t()
  def total(stopwatch), do: Stopwatch.total(stopwatch)

  @doc "Starts or resumes time tracking."
  @spec start(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def start(stopwatch), do: Stopwatch.start(stopwatch)

  @doc "Stops time tracking."
  @spec stop(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def stop(stopwatch), do: Stopwatch.stop(stopwatch)

  @doc "Adds the current lap to the previous laps and starts a new one."
  @spec lap(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def lap(stopwatch), do: Stopwatch.lap(stopwatch)

  @doc "Resets the current lap and clears the previous laps."
  @spec reset(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def reset(stopwatch), do: Stopwatch.reset(stopwatch)
end

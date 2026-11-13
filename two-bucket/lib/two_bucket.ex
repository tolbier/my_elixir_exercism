defmodule TwoBucket do
  @moduledoc """
  Measures an exact amount of water using two buckets of different sizes.
  """

  defstruct bucket_one: 0, bucket_two: 0, moves: 0
  @type t :: %__MODULE__{bucket_one: integer, bucket_two: integer, moves: integer}

  @type bucket :: :one | :two
  @typep contents :: {non_neg_integer(), non_neg_integer()}
  @typep state :: %{
           size_one: pos_integer(),
           size_two: pos_integer(),
           goal: pos_integer(),
           moves: pos_integer(),
           frontier: MapSet.t(contents()),
           visited: MapSet.t(contents())
         }

  @error_impossible {:error, :impossible}

  @doc """
  Find the quickest way to fill a bucket with some amount of water from two buckets of specific sizes.
  """
  @spec measure(
          size_one :: pos_integer(),
          size_two :: pos_integer(),
          goal :: pos_integer(),
          start_bucket :: bucket()
        ) :: {:ok, t()} | {:error, :impossible}
  def measure(size_one, size_two, goal, start_bucket) do
    bfs_levels(%{
      size_one: size_one,
      size_two: size_two,
      goal: goal,
      moves: 1,
      frontier: MapSet.new([first_contents(start_bucket, size_one, size_two)]),
      visited: MapSet.new([{0, 0}, {size_one, 0}, {0, size_two}])
    })
  end

  @spec first_contents(bucket(), pos_integer(), pos_integer()) :: contents()
  defp first_contents(:one, size_one, _size_two), do: {size_one, 0}
  defp first_contents(:two, _size_one, size_two), do: {0, size_two}

  @spec bfs_levels(state()) :: {:ok, t()} | {:error, :impossible}
  defp bfs_levels(%{frontier: frontier, moves: moves} = state) do
    cond do
      Enum.empty?(frontier) ->
        @error_impossible

      found = find_goal(state) ->
        success(found, moves)

      true ->
        state
        |> next_level()
        |> bfs_levels()
    end
  end

  @spec find_goal(state()) :: contents() | nil
  defp find_goal(%{frontier: frontier} = state), do: Enum.find(frontier, &goal?(&1, state))

  @spec next_level(state()) :: state()
  defp next_level(%{visited: visited, moves: moves} = state) do
    next_frontier = expand_frontier(state)

    %{
      state
      | frontier: next_frontier,
        visited: MapSet.union(visited, next_frontier),
        moves: moves + 1
    }
  end

  # Contents reachable in one move from the frontier that have not been visited yet.
  @spec expand_frontier(state()) :: MapSet.t(contents())
  defp expand_frontier(%{frontier: frontier, visited: visited} = state) do
    frontier
    |> Enum.flat_map(&next_contents(&1, state))
    |> MapSet.new()
    |> MapSet.difference(visited)
  end

  @spec success(contents(), pos_integer()) :: {:ok, t()}
  defp success({one, two}, moves) do
    {:ok, %__MODULE__{bucket_one: one, bucket_two: two, moves: moves}}
  end

  @spec goal?(contents(), state()) :: boolean()
  defp goal?({one, two}, %{goal: goal}), do: one == goal or two == goal

  @spec next_contents(contents(), state()) :: [contents()]
  defp next_contents({one, two}, %{size_one: size_one, size_two: size_two}) do
    one_to_two = min(one, size_two - two)
    two_to_one = min(two, size_one - one)

    [
      # fill
      {size_one, two},
      {one, size_two},
      # empty
      {0, two},
      {one, 0},
      # pour
      {one - one_to_two, two + one_to_two},
      {one + two_to_one, two - two_to_one}
    ]
  end
end

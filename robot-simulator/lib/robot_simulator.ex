defmodule RobotSimulator do
  @moduledoc "Simulates a robot moving and turning on a grid."

  @type robot() :: {direction, position}
  @type direction() :: :north | :east | :south | :west
  @type position() :: {integer(), integer()}

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(term(), term()) :: robot() | {:error, String.t()}
  def create(direction \\ :north, position \\ {0, 0})

  def create(direction, position) do
    with :ok <- validate_direction(direction),
         :ok <- validate_position(position) do
      {direction, position}
    end
  end

  @spec validate_direction(term()) :: :ok | {:error, String.t()}
  defp validate_direction(direction) when direction in [:north, :east, :south, :west], do: :ok
  defp validate_direction(_), do: {:error, "invalid direction"}

  @spec validate_position(term()) :: :ok | {:error, String.t()}
  defp validate_position({x, y}) when is_integer(x) and is_integer(y), do: :ok
  defp validate_position(_), do: {:error, "invalid position"}

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot(), instructions :: String.t()) :: robot() | {:error, String.t()}
  def simulate(robot, ""), do: robot

  def simulate(robot, <<action, rest::binary>>) when action in ~c"ALR" do
    robot |> move(action) |> simulate(rest)
  end

  def simulate(_robot, _instructions), do: {:error, "invalid instruction"}

  @spec move(robot(), ?A | ?L | ?R) :: robot()
  defp move(robot, ?A), do: advance(robot)
  defp move(robot, ?L), do: left(robot)
  defp move(robot, ?R), do: right(robot)

  @spec advance(robot()) :: robot()
  defp advance({:north, {x, y}}), do: {:north, {x, y + 1}}
  defp advance({:south, {x, y}}), do: {:south, {x, y - 1}}
  defp advance({:west, {x, y}}), do: {:west, {x - 1, y}}
  defp advance({:east, {x, y}}), do: {:east, {x + 1, y}}

  @spec left(robot()) :: robot()
  defp left({:north, position}), do: {:west, position}
  defp left({:west, position}), do: {:south, position}
  defp left({:east, position}), do: {:north, position}
  defp left({:south, position}), do: {:east, position}

  @spec right(robot()) :: robot()
  defp right({:north, position}), do: {:east, position}
  defp right({:west, position}), do: {:north, position}
  defp right({:east, position}), do: {:south, position}
  defp right({:south, position}), do: {:west, position}

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot) :: direction()
  def direction({direction, _}), do: direction

  @doc """
  Return the robot's position.
  """
  @spec position(robot) :: position()
  def position({_, position}), do: position
end

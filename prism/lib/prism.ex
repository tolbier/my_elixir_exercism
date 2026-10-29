defmodule Prism do
  @moduledoc """
  Traces a laser's path through a collection of prisms.
  """

  @type start :: %{angle: number(), x: number(), y: number()}
  @type prism :: %{id: integer(), angle: number(), x: number(), y: number()}

  @doc """
  Finds the sequence of prisms that the laser will hit.
  """
  @spec find_sequence(prisms :: [prism()], start :: start()) :: [integer()]
  def find_sequence(prisms, start) do
    do_find_sequence(prisms, start, [])
  end

  @spec do_find_sequence([prism()], start(), [integer()]) :: [integer()]
  defp do_find_sequence(prisms, start, acc) do
    case Physics.closest_collision(prisms, start) do
      :no_collision ->
        Enum.reverse(acc)

      prism ->
        next_start = %{angle: prism.angle + start.angle, x: prism.x, y: prism.y}
        do_find_sequence(prisms, next_start, [prism.id | acc])
    end
  end
end

defmodule Physics do
  @moduledoc """
  Provides geometry calculations for laser rays.
  """

  @collision_tolerance 0.01

  @spec closest_collision([Prism.prism()], Prism.start()) :: Prism.prism() | :no_collision
  def closest_collision(prisms, start) do
    prisms
    |> Enum.flat_map(fn prism ->
      case find_collision(prism.x, prism.y, start.x, start.y, start.angle) do
        {:collision, distance} -> [{prism, distance}]
        :no_collision -> []
      end
    end)
    |> Enum.min_by(fn {_, distance} -> distance end, fn -> :no_collision end)
    |> case do
      {prism, _distance} -> prism
      :no_collision -> :no_collision
    end
  end

  @doc """
  Finds a point ahead of the ray and within 0.01 units of its path.

  Returns `{:collision, distance}` with the Euclidean distance from `{x0, y0}`
  to `{x, y}`, or `:no_collision` when the ray misses the point.
  """
  @spec find_collision(number(), number(), number(), number(), number()) ::
          {:collision, float()} | :no_collision
  def find_collision(x, y, x0, y0, degrees) do
    radians = degrees * :math.pi() / 180
    sin = :math.sin(radians)
    cos = :math.cos(radians)
    dx = x - x0
    dy = y - y0

    forward_distance = dx * cos + dy * sin
    perpendicular_distance = abs(dx * sin - dy * cos)

    if forward_distance > 0 and perpendicular_distance < @collision_tolerance do
      {:collision, :math.sqrt(dx * dx + dy * dy)}
    else
      :no_collision
    end
  end
end
